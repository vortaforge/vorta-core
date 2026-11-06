#!/usr/bin/env python3
"""Make every `nbt` text component render predictably on 26.1+ (pack format 122).

The problem
-----------
A text component that reads NBT — `{"storage":"ns:path","nbt":"key"}` — does
not render the way most people expect:

  * A **string** value renders WITH its quotes. Storing `"Example Text"`
    prints `"Example Text"`, quotes and all, unless `interpret` is set.
  * A **numeric or boolean** value renders with vanilla's own decoration,
    so a stored `1b` prints as a coloured `1b` rather than a plain `1`.

The fix is to say what you mean on every such component:

  {"storage":"ns:path","nbt":"key","interpret":false,"plain":true}

`interpret:false` — do not parse the value as a nested text component.
`plain:true`      — render the raw value: no quotes around strings, no
                    vanilla colouring or type suffix on numbers.

Leaving either key out is what produces the surprise, and because the
default differs per NBT type the bug is invisible until the stored value
happens to be the wrong type.

What this does
--------------
Scans .mcfunction files for text-component objects containing an `"nbt"`
key and adds the missing `plain` / `interpret` keys. An explicit value
already in the file is never overwritten, so a component that genuinely
wants `interpret:true` is left alone.

Idempotent, and reports every component it changes.

Usage
-----
    python3 archived/tools/fix_text_components.py                 # report only
    python3 archived/tools/fix_text_components.py --fix           # rewrite in place
    python3 archived/tools/fix_text_components.py --root packs/X  # limit the scan
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

# Commands that take a text component argument.
TEXT_COMMANDS = re.compile(
    r"^\$?(?:execute\b.*?\brun\s+)?(?:tellraw|title|bossbar\s+set\s+\S+\s+name|"
    r"item\s+modify|dialog|return\s+run\s+tellraw)\b"
)

HAS_NBT = re.compile(r'"nbt"\s*:')
HAS_PLAIN = re.compile(r'"plain"\s*:')
HAS_INTERPRET = re.compile(r'"interpret"\s*:')


def find_objects(text: str) -> list[tuple[int, int]]:
    """Return (start, end) spans of top-level `{...}` groups in a command line.

    String-aware so braces inside string literals do not confuse the scan.
    """
    spans: list[tuple[int, int]] = []
    depth = 0
    start = -1
    in_string = False
    escaped = False

    for index, char in enumerate(text):
        if in_string:
            if escaped:
                escaped = False
            elif char == "\\":
                escaped = True
            elif char == '"':
                in_string = False
            continue

        if char == '"':
            in_string = True
        elif char == "{":
            if depth == 0:
                start = index
            depth += 1
        elif char == "}":
            if depth > 0:
                depth -= 1
                if depth == 0 and start >= 0:
                    spans.append((start, index + 1))

    return spans


def patch_object(obj: str) -> tuple[str, list[str]]:
    """Add missing plain/interpret keys to one component object."""
    if not HAS_NBT.search(obj):
        return obj, []

    added: list[str] = []
    body = obj

    if not HAS_PLAIN.search(body):
        body = body[:-1] + ',"plain":true}'
        added.append("plain")

    if not HAS_INTERPRET.search(body):
        body = body[:-1] + ',"interpret":false}'
        added.append("interpret")

    return body, added


def process_line(line: str) -> tuple[str, list[str]]:
    stripped = line.strip()
    if not stripped or stripped.startswith("#"):
        return line, []
    if not TEXT_COMMANDS.match(stripped):
        return line, []
    if '"nbt"' not in line:
        return line, []

    added_all: list[str] = []
    result: list[str] = []
    cursor = 0

    for start, end in find_objects(line):
        result.append(line[cursor:start])
        patched, added = patch_object(line[start:end])
        result.append(patched)
        added_all.extend(added)
        cursor = end

    result.append(line[cursor:])
    return "".join(result), added_all


def process(path: Path, fix: bool) -> list[tuple[int, list[str], str]]:
    findings: list[tuple[int, list[str], str]] = []
    original = path.read_text(encoding="utf-8", errors="replace")
    out_lines = []

    for lineno, line in enumerate(original.splitlines(), 1):
        patched, added = process_line(line)
        if added:
            findings.append((lineno, added, line.strip()[:100]))
        out_lines.append(patched if fix else line)

    if fix and findings:
        newline = "\n" if original.endswith("\n") or not original else ""
        path.write_text("\n".join(out_lines) + newline, encoding="utf-8")

    return findings


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--root", default=".", help="directory to scan (default: repo root)")
    parser.add_argument("--fix", action="store_true", help="rewrite files in place")
    parser.add_argument(
        "--exclude",
        action="append",
        default=["build/", "archived/"],
        help="path fragments to skip (repeatable)",
    )
    args = parser.parse_args()

    root = Path(args.root)
    if not root.is_dir():
        print(f"error: {root} is not a directory", file=sys.stderr)
        return 2

    total = 0
    files_changed = 0

    for path in sorted(root.rglob("*.mcfunction")):
        posix = path.as_posix()
        if any(fragment in posix for fragment in args.exclude):
            continue

        findings = process(path, args.fix)
        if not findings:
            continue

        files_changed += 1
        total += len(findings)
        print(f"{posix}")
        for lineno, added, shown in findings:
            print(f"  {lineno:>5}  +{','.join(added):<20}  {shown}")

    verb = "fixed" if args.fix else "would fix"
    print()
    print(f"{verb} {total} component(s) in {files_changed} file(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
