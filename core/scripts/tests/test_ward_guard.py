"""Offline tests for archived/tools/ward/ward_guard.py.

Ward was archived with the datapack programme on 2026-11-05. The tests stay
here (they run in the normal repository suite) so the archived harness cannot
be quietly edited into something unsafe if it is ever restored. No Minecraft
server is started: the "server" is a plain Python process that only opens a
TCP socket."""
import os
import subprocess
import sys
import tempfile
import time
import unittest

sys.path.insert(0, os.path.join(os.path.dirname(__file__), "..", "..", "archived", "tools", "ward"))
import ward_guard  # noqa: E402

LISTENER = (
    "import socket,sys,time;"
    "s=socket.socket();s.bind((sys.argv[1],0));s.listen();"
    "print(s.getsockname()[1],flush=True);time.sleep(30)"
)


class Listener:
    def __init__(self, host):
        self.proc = subprocess.Popen([sys.executable, "-c", LISTENER, host],
                                     stdout=subprocess.PIPE, text=True)
        self.port = int(self.proc.stdout.readline())

    def close(self):
        self.proc.kill()
        self.proc.wait()
        # The stdout pipe stays open otherwise, and Python reports it as an
        # unclosed file at interpreter shutdown.
        if self.proc.stdout:
            self.proc.stdout.close()


class SeedTests(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp(prefix="ward-guard-")

    def test_seed_locks_properties_and_keeps_others(self):
        with open(os.path.join(self.dir, "server.properties"), "w") as fh:
            fh.write("motd=hello\nserver-ip=0.0.0.0\nwhite-list=false\n")
        ward_guard.seed(self.dir)
        props, _ = ward_guard.read_properties(os.path.join(self.dir, "server.properties"))
        self.assertEqual(props["motd"], "hello")
        self.assertEqual(ward_guard.check_properties(self.dir), [])
        for name in ("whitelist.json", "ops.json"):
            with open(os.path.join(self.dir, name)) as fh:
                self.assertEqual(fh.read().strip(), "[]")

    def test_tampered_properties_are_reported(self):
        ward_guard.seed(self.dir)
        path = os.path.join(self.dir, "server.properties")
        with open(path) as fh:
            text = fh.read().replace("server-ip=127.0.0.1", "server-ip=")
        with open(path, "w") as fh:
            fh.write(text)
        self.assertTrue(any("server-ip" in p for p in ward_guard.check_properties(self.dir)))

    def test_eula_is_not_accepted_unless_explicitly_enabled(self):
        os.environ.pop("WARD_ACCEPT_MINECRAFT_EULA", None)
        ward_guard.seed(self.dir)
        self.assertFalse(os.path.exists(os.path.join(self.dir, "eula.txt")))


class VerifyTests(unittest.TestCase):
    def setUp(self):
        self.dir = tempfile.mkdtemp(prefix="ward-guard-")
        ward_guard.seed(self.dir)
        self.listener = None

    def tearDown(self):
        if self.listener:
            self.listener.close()

    def start(self, host):
        self.listener = Listener(host)
        with open(os.path.join(self.dir, "ward.pid"), "w") as fh:
            fh.write(str(self.listener.proc.pid))
        time.sleep(0.1)

    def test_loopback_listener_passes(self):
        self.start("127.0.0.1")
        self.assertEqual(ward_guard.verify(self.dir), [])

    def test_wildcard_listener_is_rejected(self):
        # Negative control: a server reachable from outside loopback must fail.
        self.start("0.0.0.0")
        problems = ward_guard.verify(self.dir)
        self.assertTrue(any("outside loopback" in p for p in problems), problems)

    def test_missing_pid_file_fails_closed(self):
        self.assertTrue(any("ward.pid" in p for p in ward_guard.verify(self.dir)))

    def test_process_without_sockets_fails_closed(self):
        proc = subprocess.Popen([sys.executable, "-c", "import time;time.sleep(30)"])
        self.addCleanup(proc.wait)
        self.addCleanup(proc.kill)
        with open(os.path.join(self.dir, "ward.pid"), "w") as fh:
            fh.write(str(proc.pid))
        self.assertTrue(any("cannot prove" in p for p in ward_guard.verify(self.dir)))


class DiscoverTests(unittest.TestCase):
    def test_only_packs_with_test_functions_are_returned(self):
        root = tempfile.mkdtemp(prefix="ward-discover-")
        for pack, has_test in (("a", True), ("b", False)):
            base = os.path.join(root, "packs", pack)
            os.makedirs(os.path.join(base, "data", "ns", "test" if has_test else "function"))
            with open(os.path.join(base, "pack.mcmeta"), "w") as fh:
                fh.write("{}")
            with open(os.path.join(base, "data", "ns",
                                   "test" if has_test else "function",
                                   "x.mcfunction"), "w") as fh:
                fh.write("say x\n")
        self.assertEqual(ward_guard.discover(root), ["packs/a"])


if __name__ == "__main__":
    unittest.main()
