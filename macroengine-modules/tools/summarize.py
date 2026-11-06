#!/usr/bin/env python3
"""Print a Markdown summary of a split, for a CI job summary.

Kept in a file rather than inline in the workflow because it is logic, not glue:
nesting a Python heredoc inside a shell heredoc inside YAML is three levels of
quoting where a single mis-escaped backtick silently produces a broken summary
instead of an error. As a script it can be run and read locally.

Usage:
    python3 tools/summarize.py modules.json
    python3 tools/summarize.py modules.json --source "vortaforge/core@main"
"""
from __future__ import annotations

import argparse
import json
import sys
from pathlib import Path


def summarize(data: dict, source: str | None = None) -> str:
    modules = data.get("modules", [])
    total_files = data.get("totalFiles", sum(m.get("files", 0) for m in modules))

    slots = data.get("hookSlots", {})
    empty = sorted(name for name, meta in slots.items() if meta.get("empty"))
    returning = sorted(name for name, meta in slots.items() if meta.get("returns"))

    lines = [
        f"**{total_files} files across {len(modules)} packs.**",
        "",
        "| Pack | Files | Hook contributions | Published |",
        "|---|---:|---|---:|",
    ]
    for module in sorted(modules, key=lambda m: (-m.get("files", 0), m.get("name", ""))):
        hooks = ", ".join(sorted(module.get("hooks", {}))) or "—"
        published = len(module.get("publishes", []))
        lines.append(
            f"| `{module['namespace']}` | {module['files']} | {hooks} | {published} |"
        )

    lines += ["", "**Hook slots.**"]
    if slots:
        lines.append(
            f"{len(slots)} total: {len(empty)} open for third parties "
            f"(`{', '.join(empty) or 'none'}`)"
        )
        if returning:
            lines.append(
                f"Value-returning: `{'`, `'.join(returning)}` — a tag returns the "
                f"sum of its contributors, which is exact while there is one."
            )
    else:
        lines.append("No hook slot metadata: `modules.json` is from an older splitter.")

    if source:
        lines += ["", f"Source pack: `{source}`"]

    return "\n".join(lines) + "\n"


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("manifest", type=Path, nargs="?", default=Path("modules.json"))
    parser.add_argument("--source", default=None)
    args = parser.parse_args(argv)

    try:
        data = json.loads(args.manifest.read_text(encoding="utf-8"))
    except FileNotFoundError:
        print(f"`{args.manifest}` not found: the split did not run.", file=sys.stderr)
        return 1
    except json.JSONDecodeError as exc:
        print(f"`{args.manifest}` is not valid JSON: {exc}", file=sys.stderr)
        return 1

    print(summarize(data, args.source))
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
