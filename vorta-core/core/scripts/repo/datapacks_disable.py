#!/usr/bin/env python3
"""datapacks_disable - the datapack programme kill switch, as a CLI.

The switch itself is the repository-root file `datapacks.disabled.json`
(`"enabled": false`). Everything that could produce, ship or run a datapack
reads it: scripts/repo/datapack_guard.py, the Gradle tasks (checkDatapackSwitch,
checkArchive, zipPacks, mergeDatapacks) and CI. A missing switch file counts as
**disabled** - fail-closed.

Commands
--------
  status                     show whether datapacks are enabled, and why
  disable [--reason TEXT]    disable (creates/updates the switch + marker)
  enable --token TOKEN --reason TEXT
                             re-enable; the token is the one recorded in
                             datapacks.disabled.json ("reenable_token"), so a
                             flip cannot happen by accident or by a stray
                             automation commit
  verify                     exit 1 unless the whole disabled state is
                             consistent (switch, marker, registry, empty packs/,
                             no live datapack tooling)

Exit codes: 0 ok, 1 blocked/inconsistent, 2 usage error.
Only the Python standard library is used; no network access.
"""
from __future__ import annotations

import argparse
import datetime as _dt
import json
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
SWITCH = ROOT / "datapacks.disabled.json"
MARKER = ROOT / "archived" / "datapacks.disabled"
REGISTRY = ROOT / "archived" / "archive.json"

LIVE_DATAPACK_PATHS = (
    "scripts/dpgen",
    "scripts/datapack_lint",
    "scripts/lint_datapacks.sh",
    "scripts/ward_ci.sh",
    "scripts/ward_guard.py",
    "mods/datapack-blocker",
    "examples/template-datapack",
    "packs/merge-manifest.json",
    ".github/workflows/ward.yml",
)

MARKER_BODY = """\
DATAPACKS DISABLED - vortaforge/core

The datapack programme in this repository is retired and HARD-DISABLED.
Read /datapacks.disabled.json for the switch and archived/README.md for the
policy, the reason and the list of everything that was archived.

Re-enabling is deliberate and needs the token recorded in
datapacks.disabled.json:

    python3 scripts/repo/datapacks_disable.py enable --token <token> --reason "..."
"""


def read_switch() -> dict:
    try:
        return json.loads(SWITCH.read_text(encoding="utf-8"))
    except FileNotFoundError:
        return {"enabled": False, "reason": "switch file is missing (fail-closed)"}
    except Exception as exc:  # noqa: BLE001
        return {"enabled": False, "reason": f"switch file is unreadable: {exc} (fail-closed)"}


def write_switch(data: dict) -> None:
    SWITCH.write_text(json.dumps(data, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")


def cmd_status(_args: argparse.Namespace) -> int:
    data = read_switch()
    enabled = data.get("enabled") is True
    print(f"[datapacks_disable] programme=datapacks enabled={str(enabled).lower()}")
    print(f"[datapacks_disable] since={data.get('since', '?')} approved_by={data.get('approved_by', '?')}")
    reason = data.get("reason") or data.get("disabled_reason") or ""
    if reason:
        print(f"[datapacks_disable] reason: {reason}")
    print(f"[datapacks_disable] marker={'present' if MARKER.is_file() else 'MISSING'}")
    return 0


def cmd_disable(args: argparse.Namespace) -> int:
    data = read_switch()
    today = _dt.date.today().isoformat()
    data.update({
        "schema_version": data.get("schema_version", 1),
        "programme": "datapacks",
        "enabled": False,
        "since": data.get("since") or today,
        "disabled_on": today,
        "disabled_reason": args.reason or data.get("disabled_reason") or "disabled by datapacks_disable.py",
        "approved_by": data.get("approved_by", "vortaforge maintainer"),
        "registry": data.get("registry", "archived/archive.json"),
        "marker": data.get("marker", "archived/datapacks.disabled"),
    })
    write_switch(data)
    MARKER.parent.mkdir(parents=True, exist_ok=True)
    MARKER.write_text((args.reason + "\n\n" if args.reason else "") + MARKER_BODY, encoding="utf-8")
    print("[datapacks_disable] datapacks are DISABLED. The guard blocks new datapack content.")
    return 0


def cmd_enable(args: argparse.Namespace) -> int:
    data = read_switch()
    expected = data.get("reenable_token")
    if not expected:
        print("[datapacks_disable] ERROR no reenable_token is recorded in "
              "datapacks.disabled.json; add one deliberately before enabling.", file=sys.stderr)
        return 2
    if args.token != expected:
        print("[datapacks_disable] ERROR token does not match datapacks.disabled.json.", file=sys.stderr)
        return 2
    if not args.reason or len(args.reason.strip()) < 20:
        print("[datapacks_disable] ERROR --reason must say why datapacks are being "
              "re-enabled (>= 20 chars).", file=sys.stderr)
        return 2
    data.update({
        "enabled": True,
        "enabled_on": _dt.date.today().isoformat(),
        "enabled_reason": args.reason.strip(),
        "enabled_by": args.by,
    })
    write_switch(data)
    if MARKER.exists():
        MARKER.unlink()
    print("[datapacks_disable] datapacks are ENABLED. Note that archived/packs/* are still "
          "disarmed in archived/archive.json and stay out of the build until they are "
          "moved back to packs/ with registry entries removed.")
    return 0


def cmd_verify(_args: argparse.Namespace) -> int:
    """Check that the switch is coherent, whichever way it is set.

    This used to assert `enabled is False` unconditionally, so `verify` could only
    pass while the programme was retired. The moment it was re-enabled through the
    documented `enable --token ...` path, `verify` failed and so did the CI step
    that runs it - reporting a deliberate decision as a broken repository.

    A verify step should answer "is this switch internally consistent", not "is the
    switch in the one state I assumed". Both states are legitimate; what is never
    legitimate is a switch that contradicts its own marker or its own reason.
    """
    problems: list[str] = []
    data = read_switch()
    enabled = data.get("enabled")
    if not isinstance(enabled, bool):
        problems.append("datapacks.disabled.json does not say enabled=true or enabled=false "
                        "(or is unreadable); the switch state is unknown")
    elif enabled:
        if MARKER.is_file():
            problems.append("datapacks are enabled but archived/datapacks.disabled still exists; "
                            "two sources disagree about the state")
        if not data.get("enabled_reason"):
            problems.append("datapacks are enabled with no enabled_reason recorded")
    else:
        if not MARKER.is_file():
            problems.append("archived/datapacks.disabled marker is missing")
    registry = {}
    try:
        registry = json.loads(REGISTRY.read_text(encoding="utf-8"))
    except Exception as exc:  # noqa: BLE001
        problems.append(f"archived/archive.json is unreadable: {exc}")
    projects = registry.get("projects") if isinstance(registry, dict) else None
    if not isinstance(projects, list) or not projects:
        problems.append("archived/archive.json has no projects")
    else:
        live = [p.get("id") for p in projects if isinstance(p, dict) and p.get("disarmed") is not True]
        if live:
            problems.append(f"registry entries are not disarmed: {', '.join(map(str, live))}")
    packs = ROOT / "packs"
    if packs.is_dir():
        # Its own README.md (and an optional .gitkeep) is the only thing the
        # retired tree may carry.
        extras = sorted(p.name for p in packs.iterdir()
                        if p.name not in {"README.md", ".gitkeep"})
        if extras:
            problems.append(f"packs/ is not empty: {', '.join(extras)}")
    for live_path in LIVE_DATAPACK_PATHS:
        if (ROOT / live_path).exists():
            problems.append(f"live datapack tooling still exists: {live_path}")
    check = ROOT / "scripts" / "check_archive.py"
    if check.is_file():
        proc = subprocess.run([sys.executable, str(check)], cwd=ROOT, capture_output=True, text=True, check=False)
        if proc.returncode != 0:
            problems.append("scripts/repo/check_archive.py failed:\n" + (proc.stdout + proc.stderr).strip())

    for problem in problems:
        print(f"[datapacks_disable] ERROR {problem}")
    print(f"[datapacks_disable] verify: {len(problems)} problem(s)")
    return 1 if problems else 0


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    sub = parser.add_subparsers(dest="command", required=True)
    sub.add_parser("status", help="show whether datapacks are enabled")
    disable = sub.add_parser("disable", help="engage the kill switch")
    disable.add_argument("--reason", default=None)
    enable = sub.add_parser("enable", help="disengage the kill switch (needs the token)")
    enable.add_argument("--token", required=True)
    enable.add_argument("--reason", required=True)
    enable.add_argument("--by", default="vortaforge maintainer")
    sub.add_parser("verify", help="exit 1 unless the disabled state is consistent")
    args = parser.parse_args(argv)
    return {"status": cmd_status, "disable": cmd_disable, "enable": cmd_enable,
            "verify": cmd_verify}[args.command](args)


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
