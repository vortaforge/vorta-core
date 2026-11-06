#!/usr/bin/env python3
"""Safety helper for the Ward (mcward) CI job. Standard library only.

WARNING - this repository normally never starts a Minecraft server. The ONE
documented exception is the isolated CI job .github/workflows/ward.yml, which
uses mcward to run datapack tests on a throw-away Fabric server. This helper
exists to make that server unreachable and to prove it:

  seed DIR      write a locked-down server.properties (+ empty whitelist/ops)
                into the server directory BEFORE the server starts
  verify DIR    after start: fail unless the server process (and its children)
                listen ONLY on loopback and the locked properties are intact
  discover ROOT print the packs that actually contain Ward tests
                (data/<namespace>/test/**.mcfunction); exit 1 if there are none

It never starts, stops or contacts a server itself. Run it only from CI.
"""
import argparse
import ipaddress
import os
import sys

# Every value below is chosen so that no Minecraft client can join:
#  - the listener is bound to loopback only (a remote client cannot even connect),
#  - the whitelist is on, enforced and empty (a local client is rejected),
#  - online-mode stays on (no offline-mode spoofing), status/query/rcon are off.
LOCKED_PROPERTIES = {
    "server-ip": "127.0.0.1",
    "online-mode": "true",
    "white-list": "true",
    "enforce-whitelist": "true",
    "enable-rcon": "false",
    "enable-query": "false",
    "enable-status": "false",
    "accepts-transfers": "false",
    "hide-online-players": "true",
}


# --------------------------------------------------------------------------
# server.properties
# --------------------------------------------------------------------------
def read_properties(path):
    props, order = {}, []
    if os.path.isfile(path):
        with open(path, encoding="utf-8") as fh:
            for line in fh:
                stripped = line.strip()
                if stripped and not stripped.startswith("#") and "=" in stripped:
                    key, _, value = stripped.partition("=")
                    props[key.strip()] = value.strip()
                    order.append(key.strip())
    return props, order


def seed(directory):
    """Write the locked properties, keeping any other existing property."""
    os.makedirs(directory, exist_ok=True)
    path = os.path.join(directory, "server.properties")
    props, order = read_properties(path)
    for key, value in LOCKED_PROPERTIES.items():
        if key not in props:
            order.append(key)
        props[key] = value
    with open(path, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("# Written by scripts/ward_guard.py: CI-only, loopback-only, whitelist enforced.\n")
        for key in order:
            fh.write(f"{key}={props[key]}\n")
    for name in ("whitelist.json", "ops.json"):
        with open(os.path.join(directory, name), "w", encoding="utf-8", newline="\n") as fh:
            fh.write("[]\n")
    # The Minecraft EULA is never accepted on the maintainers' behalf.
    if os.environ.get("WARD_ACCEPT_MINECRAFT_EULA") == "true":
        with open(os.path.join(directory, "eula.txt"), "w", encoding="utf-8", newline="\n") as fh:
            fh.write("eula=true\n")
    return path


def check_properties(directory):
    props, _ = read_properties(os.path.join(directory, "server.properties"))
    return [
        f"server.properties: {key} is {props.get(key)!r}, expected {value!r}"
        for key, value in LOCKED_PROPERTIES.items()
        if props.get(key) != value
    ]


# --------------------------------------------------------------------------
# listening sockets of a process tree (Linux /proc)
# --------------------------------------------------------------------------
def process_tree(pid, proc="/proc"):
    children = {}
    for entry in os.listdir(proc):
        if not entry.isdigit():
            continue
        try:
            with open(f"{proc}/{entry}/stat", encoding="utf-8") as fh:
                stat = fh.read()
            ppid = int(stat.rsplit(")", 1)[1].split()[1])
        except (OSError, ValueError, IndexError):
            continue
        children.setdefault(ppid, []).append(int(entry))
    found, todo = set(), [pid]
    while todo:
        cur = todo.pop()
        if cur not in found:
            found.add(cur)
            todo.extend(children.get(cur, []))
    return found


def socket_inodes(pids, proc="/proc"):
    inodes = set()
    for pid in pids:
        fd_dir = f"{proc}/{pid}/fd"
        try:
            names = os.listdir(fd_dir)
        except OSError:
            continue
        for name in names:
            try:
                target = os.readlink(f"{fd_dir}/{name}")
            except OSError:
                continue
            if target.startswith("socket:["):
                inodes.add(int(target[8:-1]))
    return inodes


def parse_address(hex_ip):
    raw = bytes.fromhex(hex_ip)
    if len(raw) == 4:
        return ipaddress.IPv4Address(raw[::-1])
    words = [raw[i:i + 4][::-1] for i in range(0, 16, 4)]
    return ipaddress.IPv6Address(b"".join(words))


def is_loopback(address):
    if address.version == 6 and address.ipv4_mapped is not None:
        return address.ipv4_mapped.is_loopback
    return address.is_loopback


def bound_sockets(pids, proc="/proc"):
    """[(proto, address, port, loopback)] for every TCP listener / bound UDP socket."""
    inodes = socket_inodes(pids, proc)
    result = []
    # TCP: state 0A = LISTEN. UDP: state 07 = bound, unconnected.
    for table, proto, state in (("tcp", "tcp", "0A"), ("tcp6", "tcp", "0A"),
                                ("udp", "udp", "07"), ("udp6", "udp", "07")):
        try:
            with open(f"{proc}/net/{table}", encoding="utf-8") as fh:
                rows = fh.read().splitlines()[1:]
        except OSError:
            continue
        for row in rows:
            cols = row.split()
            if len(cols) < 10 or cols[3] != state or int(cols[9]) not in inodes:
                continue
            ip_hex, _, port_hex = cols[1].partition(":")
            address = parse_address(ip_hex)
            result.append((proto, str(address), int(port_hex, 16), is_loopback(address)))
    return result


def verify(directory):
    problems = check_properties(directory)
    try:
        with open(os.path.join(directory, "ward.pid"), encoding="utf-8") as fh:
            pid = int(fh.read().strip())
    except (OSError, ValueError):
        return problems + ["ward.pid is missing: cannot identify the server process"]
    if not os.path.isdir(f"/proc/{pid}"):
        return problems + [f"server process {pid} is not running"]
    sockets = bound_sockets(process_tree(pid))
    if not sockets:
        problems.append("no listening socket found for the server process: cannot prove it is loopback-only")
    for proto, address, port, loopback in sockets:
        print(f"  {proto} {address}:{port} {'loopback' if loopback else 'NOT LOOPBACK'}")
        if not loopback:
            problems.append(f"{proto} socket {address}:{port} is reachable from outside loopback")
    return problems


# --------------------------------------------------------------------------
# which packs have Ward tests
# --------------------------------------------------------------------------
def discover(root):
    packs = []
    base = os.path.join(root, "packs")
    for name in sorted(os.listdir(base)) if os.path.isdir(base) else []:
        pack = os.path.join(base, name)
        data = os.path.join(pack, "data")
        if not (os.path.isfile(os.path.join(pack, "pack.mcmeta")) and os.path.isdir(data)):
            continue
        for ns in sorted(os.listdir(data)):
            test_dir = os.path.join(data, ns, "test")
            if os.path.isdir(test_dir) and any(
                f.endswith(".mcfunction") for _, _, files in os.walk(test_dir) for f in files
            ):
                packs.append(os.path.relpath(pack, root).replace(os.sep, "/"))
                break
    return packs


def main(argv=None):
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = ap.add_subparsers(dest="cmd", required=True)
    for name in ("seed", "verify", "discover"):
        sub.add_parser(name).add_argument("path")
    args = ap.parse_args(argv)

    if args.cmd == "seed":
        print(f"seeded {seed(args.path)}")
        return 0
    if args.cmd == "verify":
        problems = verify(args.path)
        for problem in problems:
            print(f"ERROR {problem}", file=sys.stderr)
        print("ward_guard: server is loopback-only and locked" if not problems else "ward_guard: FAILED")
        return 1 if problems else 0
    packs = discover(args.path)
    for pack in packs:
        print(pack)
    if not packs:
        print("ward_guard: no datapack contains Ward tests (data/<ns>/test/**.mcfunction)", file=sys.stderr)
    return 0 if packs else 1


if __name__ == "__main__":
    sys.exit(main())
