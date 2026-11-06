#!/usr/bin/env python3
"""Compare a freshly generated `modules.json` with the committed baseline.

`verify.py` answers "is this layout internally consistent?" It does not answer
"is this the layout we reviewed?" - both a split that dropped a module and a split
that put every id in the wrong pack can be perfectly consistent. This script covers
that second question.

It is what the upstream canary runs after re-splitting against the current source
pack: the source pack lives in another repository, so the split can change shape
without a single commit landing here.

Exit codes:
    0  the shape matches, or there is no baseline to compare against
    1  the shape drifted in a way that needs a human
    2  the inputs are unreadable

Usage:
    python3 tools/check_shape.py                 # compare with HEAD:modules.json
    python3 tools/check_shape.py --baseline old.json
"""
from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

# A pack losing more than this fraction of its files is not a refactor, it is a
# module that has stopped being populated. Deliberately a large threshold: upstream
# genuinely does move things around, and a canary that cries wolf gets ignored.
SHRINK_LIMIT = 0.5
# The mirror image. Doubling is the signature of ids landing in the wrong module -
# e.g. a prefix rule that stopped matching and dumped a neighbour's files here.
GROWTH_LIMIT = 2.0
# Absolute floors so the thresholds above do not fire on tiny numbers: a pack going
# from 2 files to 1 is a 50% loss and completely uninteresting.
MIN_FILES_FOR_RATIO = 10
# Total file count is allowed to move by this many before it counts as drift.
TOTAL_SLACK_MIN = 50
TOTAL_SLACK_FRACTION = 10


def load_baseline(path: Path | None) -> dict | None:
    """The committed manifest, from a file or from git."""
    if path is not None:
        try:
            return json.loads(path.read_text(encoding="utf-8"))
        except (FileNotFoundError, json.JSONDecodeError) as exc:
            print(f"cannot read baseline {path}: {exc}", file=sys.stderr)
            raise SystemExit(2)

    result = subprocess.run(
        ["git", "show", f"HEAD:{Path('modules.json').as_posix()}"],
        capture_output=True, text=True,
    )
    if result.returncode != 0:
        return None
    try:
        return json.loads(result.stdout)
    except json.JSONDecodeError:
        return None


def compare(baseline: dict, current: dict) -> tuple[list[str], list[str], list[str]]:
    """Return (errors, notices, summary lines)."""
    errors: list[str] = []
    notices: list[str] = []

    before = {m["name"]: m.get("files", 0) for m in baseline.get("modules", [])}
    after = {m["name"]: m.get("files", 0) for m in current.get("modules", [])}

    for name in sorted(set(before) - set(after)):
        errors.append(f"pack `{name}` disappeared from the split "
                      f"(had {before[name]} files)")

    for name in sorted(set(after) - set(before)):
        # Not an error: upstream may legitimately add a feature area. Reported so
        # somebody updates the baseline on purpose.
        notices.append(f"pack `{name}` is new ({after[name]} files) - "
                       f"review it, then commit the new modules.json")

    for name in sorted(set(before) & set(after)):
        was, now = before[name], after[name]
        if was < MIN_FILES_FOR_RATIO:
            continue
        if now < was * SHRINK_LIMIT:
            errors.append(f"pack `{name}` fell from {was} to {now} files "
                          f"({100 - int(now * 100 / was)}% loss)")
        elif now > was * GROWTH_LIMIT:
            errors.append(f"pack `{name}` grew from {was} to {now} files - "
                          f"ids may be landing in the wrong module")

    was_total = baseline.get("totalFiles", 0)
    now_total = current.get("totalFiles", 0)
    if was_total:
        slack = max(TOTAL_SLACK_MIN, was_total // TOTAL_SLACK_FRACTION)
        if abs(now_total - was_total) > slack:
            errors.append(f"total files moved from {was_total} to {now_total} "
                          f"(more than the {slack}-file slack)")

    summary = [
        f"baseline: {len(before)} packs, {was_total} files",
        f"current:  {len(after)} packs, {now_total} files",
    ]
    return errors, notices, summary


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--current", type=Path, default=Path("modules.json"))
    parser.add_argument("--baseline", type=Path, default=None,
                        help="default: the committed modules.json from HEAD")
    args = parser.parse_args(argv)

    try:
        current = json.loads(args.current.read_text(encoding="utf-8"))
    except (FileNotFoundError, json.JSONDecodeError) as exc:
        print(f"cannot read {args.current}: {exc}", file=sys.stderr)
        return 2

    baseline = load_baseline(args.baseline)
    if baseline is None:
        print("no committed baseline: nothing to compare against")
        return 0

    errors, notices, summary = compare(baseline, current)

    for line in summary:
        print(line)
    for notice in notices:
        print(f"::notice title=New pack::{notice}")
    for error in errors:
        print(f"::error title=The split changed shape::{error}")

    if errors:
        print(f"\n{len(errors)} shape problem(s): verification can pass on a layout "
              f"nobody reviewed.", file=sys.stderr)
        return 1

    print("shape matches the baseline")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
