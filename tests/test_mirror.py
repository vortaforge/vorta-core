#!/usr/bin/env python3
"""Tests for scripts/mirror.py.

The two failures worth a regression test are the ones that actually happened:

* `clear()` deleted this repository's own `docs/OPERATIONS.md`, because the
  mirrored `docs/` repository shares a directory name with us. A test that only
  ever mirrors into an empty directory cannot catch that.
* The self-mirror risks nesting `vorta-core/vorta-core/vorta-core`. The exclusion
  is one line; removing it is invisible unless something asserts on depth.

Both tests run the real script against local repositories, so they check the
behaviour rather than a copy of it.
"""
from __future__ import annotations

import json
import shutil
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
MIRROR = ROOT / "scripts" / "mirror.py"


def git(*args: str, cwd: Path) -> None:
    subprocess.run(["git", *args], cwd=cwd, check=True,
                   capture_output=True, text=True)


def make_repo(path: Path, files: dict[str, str], branch: str = "main") -> Path:
    path.mkdir(parents=True, exist_ok=True)
    git("init", "-q", "-b", branch, cwd=path)
    git("config", "user.email", "t@example.invalid", cwd=path)
    git("config", "user.name", "t", cwd=path)
    write(path, files)
    git("add", "-A", cwd=path)
    git("commit", "-q", "-m", "init", cwd=path)
    return path


def write(path: Path, files: dict[str, str]) -> None:
    for rel, body in files.items():
        target = path / rel
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_text(body, encoding="utf-8")


class MirrorTest(unittest.TestCase):
    def setUp(self) -> None:
        self.tmp = Path(tempfile.mkdtemp(prefix="mirror-test-"))
        self.addCleanup(shutil.rmtree, self.tmp, True)

    def _mirror(self, work: Path, index: Path, repo: str, *extra: str) -> subprocess.CompletedProcess:
        """Run mirror.py with the clone step pointed at a local origin."""
        env_free = ["python3", str(MIRROR), "--org", "testorg",
                    "--index", str(index), "--root", str(work), *extra]
        return subprocess.run(env_free, capture_output=True, text=True,
                              cwd=self.tmp)

    def test_manifest_records_paths_and_clear_removes_only_those(self) -> None:
        """A mirror sharing a directory name must not delete our own files."""
        work = self.tmp / "work"
        work.mkdir()
        # Ours, and it must survive.
        write(work, {"docs/OPERATIONS.md": "ours", "docs/DESIGN.md": "ours"})

        index = self.tmp / "index.json"
        index.write_text(json.dumps({"org": "testorg", "repositories": [],
                                     "mirrors": {"docs": {"commit": "deadbeef",
                                                          "branch": "main"}}}),
                         encoding="utf-8")

        # Stand in for a previous mirror having written these.
        write(work, {"docs/index.html": "theirs", "docs/docs/api.html": "theirs"})
        manifest = {"repo": "testorg/docs", "branch": "main", "commit": "deadbeef",
                    "paths": ["index.html", "docs/api.html"]}
        (work / "docs" / ".mirror.json").write_text(json.dumps(manifest),
                                                    encoding="utf-8")

        sys.path.insert(0, str(ROOT / "scripts"))
        import mirror  # noqa: PLC0415

        mirror.clear(work / "docs")

        self.assertTrue((work / "docs" / "OPERATIONS.md").is_file())
        self.assertTrue((work / "docs" / "DESIGN.md").is_file())
        self.assertFalse((work / "docs" / "index.html").exists())
        self.assertFalse((work / "docs" / ".mirror.json").exists())

    def test_self_mirror_is_not_mirrored_at_all(self) -> None:
        """vorta-core must not mirror itself, or the sync never settles.

        The copy could only be taken from the previous commit, so every sync
        changed the mirror, which was a commit, which changed the mirror again.
        Observed as an endless series of "sync: index refresh" commits, each one
        only moving a pointer to the commit before it.
        """
        work = self.tmp / "work"
        work.mkdir()
        origin = self.tmp / "origins" / "self"
        make_repo(origin, {"README.md": "x"})

        index = self.tmp / "index.json"
        index.write_text(json.dumps({"org": "testorg", "repositories": [],
                                     "mirrors": {}}), encoding="utf-8")
        script = (
            "import sys, pathlib\n"
            "sys.path.insert(0, %r)\n"
            "import mirror\n"
            "mirror.repository_name = lambda: 'vorta-core'\n"
            "mirror.clone = lambda org, name, branch: (pathlib.Path(%r), 'abc')\n"
            "mirror.remote_head = lambda org, name, branch: 'abc'\n"
            "mirror.discover.discover = lambda org, include_archived: "
            "[{'name': 'vorta-core', 'defaultBranch': 'main'},\n"
            " {'name': 'docs', 'defaultBranch': 'main'}]\n"
            "raise SystemExit(mirror.main(['--org','testorg','--index',%r,"
            "'--root',%r,'--apply']))\n"
        ) % (str(ROOT / "scripts"), str(origin), str(index), str(work))

        result = subprocess.run(["python3", "-c", script], capture_output=True,
                                text=True)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertFalse((work / "vorta-core").exists(),
                         "vorta-core mirrored itself")

    def test_manifest_claims_only_what_the_mirror_wrote(self) -> None:
        """A manifest that lists our own files licenses their deletion.

        `docs/` is both this repository's documentation directory and the
        destination of `vortaforge/docs`. The manifest is written by listing the
        destination, so it named `DESIGN.md` - and the next run's `clear()`
        deleted it. The manifest must come from the copy, never from the tree.
        """
        src = self.tmp / "src"
        write(src, {"index.html": "theirs"})
        dest = self.tmp / "dest"
        write(dest, {"DESIGN.md": "ours"})

        sys.path.insert(0, str(ROOT / "scripts"))
        import mirror  # noqa: PLC0415

        record = mirror.copy_tree(src, dest)

        self.assertEqual(record["written"], ["index.html"])
        self.assertNotIn("DESIGN.md", record["written"])

    def test_second_apply_keeps_our_files(self) -> None:
        """End to end: the failure only appears on the *second* run.

        The first run writes a manifest; the second reads it and clears what it
        names. Asserting on one run would pass with the bug present.

        The commit must differ between the runs. Mirror's "unchanged" fast path
        skips a repository whose commit has not moved, which is why a naive
        two-run test with a fixed sha silently tests nothing.
        """
        work = self.tmp / "work"
        work.mkdir()
        write(work, {"docs/OPERATIONS.md": "ours"})

        origin = self.tmp / "origins" / "docs"
        make_repo(origin, {"index.html": "theirs", "docs/api.html": "theirs"})

        index = self.tmp / "index.json"
        index.write_text(json.dumps({"org": "testorg", "repositories": [],
                                     "mirrors": {}}), encoding="utf-8")
        sha_file = self.tmp / "sha.txt"
        sha_file.write_text("sha-one", encoding="utf-8")

        script = (
            "import sys, pathlib\n"
            "sys.path.insert(0, %r)\n"
            "import mirror\n"
            "sha = pathlib.Path(%r).read_text().strip()\n"
            "mirror.clone = lambda org, name, branch: (pathlib.Path(%r), sha)\n"
            "mirror.remote_head = lambda org, name, branch: sha\n"
            "mirror.discover.discover = lambda org, include_archived: "
            "[{'name': 'docs', 'defaultBranch': 'main'}]\n"
            "raise SystemExit(mirror.main(['--org','testorg','--index',%r,"
            "'--root',%r,'--apply']))\n"
        ) % (str(ROOT / "scripts"), str(sha_file), str(origin), str(index), str(work))

        for attempt, sha in ((1, "sha-one"), (2, "sha-two")):
            sha_file.write_text(sha, encoding="utf-8")
            if not origin.exists():
                make_repo(origin, {"index.html": "theirs", "docs/api.html": "theirs"})
            result = subprocess.run(["python3", "-c", script], capture_output=True,
                                    text=True)
            self.assertEqual(result.returncode, 0,
                             f"run {attempt} failed: {result.stderr}")
            self.assertTrue((work / "docs" / "OPERATIONS.md").is_file(),
                            f"our file was deleted on run {attempt}")

        manifest = json.loads((work / "docs" / ".mirror.json").read_text())
        self.assertNotIn("OPERATIONS.md", manifest["paths"])


    def test_symlinks_are_dropped_not_followed(self) -> None:
        """A link can name a path outside the mirror; following one writes it in."""
        src = self.tmp / "src"
        src.mkdir()
        (src / "real.txt").write_text("x", encoding="utf-8")
        (src / "link").symlink_to("/etc/passwd")
        dest = self.tmp / "dest"
        dest.mkdir()

        sys.path.insert(0, str(ROOT / "scripts"))
        import mirror  # noqa: PLC0415

        record = mirror.copy_tree(src, dest)

        self.assertEqual(record["symlinksDropped"], 1)
        self.assertFalse((dest / "link").exists())
        self.assertTrue((dest / "real.txt").is_file())

    def test_unchanged_mirror_does_not_touch_index(self) -> None:
        """A scheduled sync that changes nothing must write nothing."""
        work = self.tmp / "work"
        work.mkdir()
        origin = self.tmp / "origins" / "docs"
        make_repo(origin, {"index.html": "theirs"})

        index = self.tmp / "index.json"
        index.write_text(json.dumps({"org": "testorg", "repositories": [],
                                     "mirrors": {}}), encoding="utf-8")
        script = (
            "import sys, pathlib\n"
            "sys.path.insert(0, %r)\n"
            "import mirror\n"
            "mirror.repository_name = lambda: 'vorta-core'\n"
            "mirror.clone = lambda org, name, branch: (pathlib.Path(%r), 'abc')\n"
            "mirror.remote_head = lambda org, name, branch: 'abc'\n"
            "mirror.discover.discover = lambda org, include_archived: "
            "[{'name': 'docs', 'defaultBranch': 'main'}]\n"
            "raise SystemExit(mirror.main(['--org','testorg','--index',%r,"
            "'--root',%r,'--apply']))\n"
        ) % (str(ROOT / "scripts"), str(origin), str(index), str(work))

        for _ in range(2):
            if not (origin / "index.html").exists():
                write(origin, {"index.html": "theirs"})
            self.assertEqual(
                subprocess.run(["python3", "-c", script], capture_output=True,
                               text=True).returncode, 0)
        first = index.read_text(encoding="utf-8")

        if not (origin / "index.html").exists():
            write(origin, {"index.html": "theirs"})
        self.assertEqual(
            subprocess.run(["python3", "-c", script], capture_output=True,
                           text=True).returncode, 0)

        self.assertEqual(index.read_text(encoding="utf-8"), first,
                         "an unchanged sync rewrote index.json")



if __name__ == "__main__":
    unittest.main(verbosity=2)
