#!/usr/bin/env python3
"""Tests for `split.py`'s output guard.

These exist because the guard was added after a real accident: `--out .` deleted the
project root, including `.git`. The tool that generates the packs is allowed to
delete its own previous output and nothing else, and "nothing else" is a property
worth pinning down with a test rather than a comment.

Run:  python3 tools/test_split_guard.py
"""
from __future__ import annotations

import sys
import tempfile
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

from split import Split  # noqa: E402


def _source(root: Path) -> Path:
    """A minimal pack layout: data/<ns>/function/thing.mcfunction."""
    src = root / "src" / "pack"
    fn = src / "data" / "macroengine" / "function"
    fn.mkdir(parents=True)
    (fn / "thing.mcfunction").write_text("say hi\n", encoding="utf-8")
    # The splitter reads the source manifest to carry its description through.
    (src / "pack.mcmeta").write_text(
        '{"pack":{"description":"test","min_format":[121,0],"max_format":[121,0]}}',
        encoding="utf-8")
    return src


def test_plain_output_directory_is_cleared():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        src = _source(root)
        out = root / "out"
        out.mkdir()
        (out / "stale.txt").write_text("old", encoding="utf-8")

        Split(src, out).write()

        assert not (out / "stale.txt").exists(), "stale output should be cleared"
        assert (out / "packs").is_dir()


def test_git_working_tree_is_refused():
    """The exact accident: output root is a checkout."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        src = _source(root)
        project = root / "project"
        (project / ".git").mkdir(parents=True)
        (project / "keep.txt").write_text("do not delete me", encoding="utf-8")

        try:
            Split(src, project).write()
        except SystemExit as exc:
            assert ".git" in str(exc) or "git working tree" in str(exc)
        else:
            raise AssertionError("writing into a git working tree must be refused")

        assert (project / "keep.txt").exists(), "refused run must not delete anything"


def test_source_overlap_is_refused():
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        src = _source(root)
        # Output *contains* the source: clearing it would delete the input.
        try:
            Split(src, root).write()
        except SystemExit:
            pass
        else:
            raise AssertionError("output that contains the source must be refused")
        assert (src / "data" / "macroengine" / "function" / "thing.mcfunction").is_file()


def test_in_place_clears_only_owned_paths():
    """`--out . --in-place` is the project layout: it must leave the project alone."""
    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        src = _source(root)
        project = root / "project"
        (project / ".git").mkdir(parents=True)
        (project / "build.gradle").write_text("// keep", encoding="utf-8")
        (project / "tools").mkdir()
        (project / "tools" / "split.py").write_text("# keep", encoding="utf-8")
        # A previous run's output, which is meant to be replaced.
        (project / "packs" / "old").mkdir(parents=True)
        (project / "modules.json").write_text("{}", encoding="utf-8")

        Split(src, project, in_place=True).write()

        assert (project / "build.gradle").is_file(), "project files must survive"
        assert (project / "tools" / "split.py").is_file()
        assert (project / ".git").is_dir()
        assert not (project / "packs" / "old").exists(), "previous packs are replaced"
        assert (project / "packs").is_dir(), "new packs are written"


def test_manifest_is_reproducible():
    """Two splits of the same input must produce the same modules.json bytes.

    Run as two separate *processes*, not two calls in one. Python randomises set
    and dict order per process via its hash seed, so a set being iterated
    unsorted is stable inside one interpreter and different across two. An earlier
    version of this test ran both splits in the same process and passed happily
    while the real build produced three different hashes in three runs - the test
    was measuring the wrong thing.

    The bug it exists for: `publishes` was built by iterating a set.
    """
    import os
    import subprocess
    import sys

    with tempfile.TemporaryDirectory() as tmp:
        root = Path(tmp)
        src = _source(root)
        script = Path(__file__).resolve().parent / "split.py"

        outputs = []
        for name in ("a", "b"):
            out = root / name
            out.mkdir()
            subprocess.run(
                [sys.executable, str(script), "--source", str(src), "--out", str(out)],
                check=True, capture_output=True,
            )
            outputs.append(out)

        a = (outputs[0] / "modules.json").read_bytes()
        b = (outputs[1] / "modules.json").read_bytes()
        assert a == b, (
            "modules.json differs between two runs of the same split in separate "
            "processes; something is iterating a set or a directory unsorted"
        )

        for path in sorted((outputs[0] / "packs").rglob("*")):
            if not path.is_file():
                continue
            rel = path.relative_to(outputs[0] / "packs")
            other = outputs[1] / "packs" / rel
            assert other.is_file(), f"{rel} missing from the second run"
            assert path.read_bytes() == other.read_bytes(), f"{rel} differs"


def _run_all() -> int:
    failures = 0
    tests = [(n, f) for n, f in sorted(globals().items())
             if n.startswith("test_") and callable(f)]
    for name, fn in tests:
        try:
            fn()
            print(f"  ok   {name}")
        except AssertionError as exc:
            failures += 1
            print(f"  FAIL {name}: {exc}")
        except Exception as exc:  # noqa: BLE001
            failures += 1
            print(f"  ERR  {name}: {type(exc).__name__}: {exc}")
    print(f"\n{len(tests) - failures}/{len(tests)} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    raise SystemExit(_run_all())
