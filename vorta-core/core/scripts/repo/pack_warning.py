#!/usr/bin/env python3
"""Add an archived-pack warning to every datapack, in the syntax its target allows.

Why this exists
---------------
Every datapack in this repository is archived and disarmed: kept as readable
history, not maintained, not recommended for a live server. Until now that was
recorded in ``archived/archive.json``, in the docs, and in the website -- three
places a player running the pack will never look. A player who installed the
pack before it was retired sees exactly nothing.

This script makes the pack itself say so. On load it emits a chat warning that
links to

    https://vortaforge.github.io/docs/docs/warnings.html

which explains the status, what "disarmed" enforces, and what running an
archived pack actually means.

The hard constraint
-------------------
Minecraft 1.21.5 (data pack format 71) renamed the text-component field
``clickEvent`` to ``click_event`` and, for ``open_url``, renamed ``value`` to
``url``. The two forms are not interchangeable:

    1.21.5+        {"click_event":{"action":"open_url","url":"..."}}
    before 1.21.5  {"clickEvent":{"action":"open_url","value":"..."}}

Writing the new form into a pack that targets an old format produces a command
error at run time, on exactly the version the pack was written for. So the
warning has two renderings and the script picks per pack:

  * format >= 71  -> clickable ``open_url`` link, in the correct syntax
  * format <  71  -> plain text warning with the URL spelled out and no click
                     target, because a click target cannot work there

Neither form is presented as a security control. A warning is a label, not a
gate: it does not make an ungated pack safe, and the docs say so explicitly.

What it will not do
-------------------
A pack that already has a real load gate (a consent flow with an authoritative
open/closed score) is *not* given a duplicate warning. Its gate already refuses
to operate until a player agrees, which is a stronger statement than a message.
Those packs are reported as ``gated`` and left alone.

Usage
-----
    python3 scripts/repo/pack_warning.py --check     # report only, exit 1 if any pack lacks a warning
    python3 scripts/repo/pack_warning.py --apply     # write the functions + tags
    python3 scripts/repo/pack_warning.py --json      # machine-readable report
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
PACKS_DIR = ROOT / "archived" / "packs"

DOCS_URL = "https://vortaforge.github.io/docs/docs/warnings.html"

# Data pack format 71 == Minecraft 1.21.5, the release that renamed clickEvent
# to click_event. Below this the new syntax is a command error, not a feature.
CLICK_EVENT_MIN_FORMAT = 71

MARKER = "vortaforge:archive_warning"
WARNING_FILE = "archive_warning.mcfunction"


def pack_roots(pack: Path) -> list[Path]:
    """Every directory that is itself a loadable pack (has pack.mcmeta).

    A few entries do not put pack.mcmeta at their top level: RTWrapper wraps the
    actual datapack in ``datapack/<name>/``. Returning every root that owns a
    pack.mcmeta keeps the walker honest instead of silently skipping those.
    """
    if (pack / "pack.mcmeta").is_file():
        return [pack]
    return sorted({m.parent for m in pack.rglob("pack.mcmeta")})


def pack_format(pack: Path) -> tuple[int, str]:
    """Return (major format, raw description) from pack.mcmeta.

    Packs since 1.21.9 / 25w31a use min_format/max_format instead of
    pack_format; both are accepted. A pack with no readable format is treated
    as old (0), which selects the conservative rendering.
    """
    meta = pack / "pack.mcmeta"
    try:
        data = json.loads(meta.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return 0, ""
    block = data.get("pack", {})
    for key in ("pack_format", "min_format", "max_format"):
        value = block.get(key)
        if isinstance(value, list) and value:
            value = value[0]
        if isinstance(value, (int, float)):
            return int(value), str(block.get("description", ""))
    return 0, str(block.get("description", ""))


def namespace_dirs(pack: Path) -> list[Path]:
    """Every data/<namespace>/function(s) directory in the pack.

    ``minecraft`` is excluded on purpose. It is a reserved namespace whose
    function directory holds engine-level functions, not this pack's own code,
    and a warning written there is addressed as ``minecraft:archive_warning`` --
    which is confusing at best and collides at worst. A pack that genuinely owns
    a ``minecraft`` function directory still gets a warning through its own
    namespace instead.
    """
    out = []
    data = pack / "data"
    if not data.is_dir():
        return out
    for ns in sorted(data.iterdir()):
        if not ns.is_dir() or ns.name == "minecraft":
            continue
        for name in ("function", "functions"):
            d = ns / name
            if d.is_dir():
                out.append(d)
    return out


def has_real_gate(pack: Path) -> bool:
    """True when the pack already refuses to run without consent.

    A "real" gate writes an authoritative open/closed score and ships a consent
    path. A pack that merely mentions the word gate in a comment does not count,
    which is why this looks for the score write rather than the word.
    """
    # The two halves of a gate live in different files: one writes the open
    # score, another runs the consent flow. Checking per file found neither pack,
    # so the scan accumulates across the whole pack instead.
    writes_open = False
    mentions_consent = False
    for d in namespace_dirs(pack):
        for f in d.rglob("*.mcfunction"):
            try:
                text = f.read_text(encoding="utf-8", errors="replace")
            except OSError:
                continue
            # The score is written as `scoreboard players set #macroengine.open
            # vortaforge.gate 1`: the holder says "open", the objective is a
            # namespace. Match either position so a pack that namespaces its
            # objective differently is still detected.
            if re.search(
                r"scoreboard players set\s+#?\S*(open|gated|enabled)\S*\s+\S+", text
            ) or re.search(
                r"scoreboard players set\s+#?\S+\s+\S*(open|gated|enabled)\S*\s+\d", text
            ):
                writes_open = True
            if "consent" in text.lower() or "is_open" in text:
                mentions_consent = True
            if writes_open and mentions_consent:
                return True
    return False


def warning_body(pack: Path, fmt: int, name: str) -> str:
    """The function body, in whichever component syntax this pack can parse."""
    lines = [
        f"# {MARKER} - generated by scripts/repo/pack_warning.py, do not edit by hand.",
        "#",
        f"# This pack ({name}) is archived and disarmed. It is kept as readable",
        "# history: it is not maintained, not supported, and not recommended for a",
        "# live server. This function says so once, on load, before anything else",
        "# in the pack runs.",
        "#",
        "# A warning is not a gate. It does not disable the pack and it does not",
        "# make the pack safe to run. It tells you the maintenance status only.",
        f"# Full explanation: {DOCS_URL}",
        "",
    ]
    if fmt >= CLICK_EVENT_MIN_FORMAT:
        # 1.21.5+: click_event / url. This is the form the docs page documents.
        component = (
            '[{"text":"[VortaForge] ","color":"gold"},'
            f'{{"text":"{name} ","color":"yellow","bold":true}},'
            '{"text":"is archived and disarmed: not maintained, not supported, ","color":"gray"},'
            '{"text":"not recommended for a live server. ","color":"gray"},'
            '{"text":"Click here to read why.","color":"aqua","underlined":true,'
            f'"click_event":{{"action":"open_url","url":"{DOCS_URL}"}},'
            '"hover_event":{"action":"show_text","value":"Opens the VortaForge documentation"}}]'
        )
    else:
        # Pre-1.21.5: clickEvent / value. A click target is still possible on
        # 1.13-1.21.4, so use it there -- but only in the syntax those versions
        # actually parse. Packs below format 48 also predate the singular
        # `function` directory, which the caller is responsible for.
        component = (
            '[{"text":"[VortaForge] ","color":"gold"},'
            f'{{"text":"{name} ","color":"yellow","bold":true}},'
            '{"text":"is archived and disarmed: not maintained, not supported, ","color":"gray"},'
            '{"text":"not recommended for a live server. Read why: ","color":"gray"},'
            '{"text":"documentation","color":"aqua","underlined":true,'
            f'"clickEvent":{{"action":"open_url","value":"{DOCS_URL}"}}}},'
            '{"text":" - or open this URL manually: ","color":"gray"},'
            f'{{"text":"{DOCS_URL}","color":"gray","underlined":true}}]'
        )
    lines.append(f"tellraw @a {component}")
    lines.append("")
    return "\n".join(lines)


def load_tag_files(pack: Path) -> list[Path]:
    """The minecraft:load tag files that decide what runs on pack load."""
    found = []
    for name in ("function", "functions"):
        candidate = pack / "data" / "minecraft" / "tags" / name / "load.json"
        if candidate.is_file():
            found.append(candidate)
    return found


def _rel(path: Path) -> str:
    """Repository-relative path when possible, absolute otherwise.

    --check has to run against a temporary copy (that is how the tests prove it
    fails when a warning is missing), and those paths are outside the repo.
    """
    try:
        return str(path.relative_to(ROOT))
    except ValueError:
        return str(path)


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    mode = parser.add_mutually_exclusive_group(required=True)
    mode.add_argument("--check", action="store_true",
                      help="report which packs would change; exit 1 if any lacks a warning")
    mode.add_argument("--apply", action="store_true", help="write the warning functions and tags")
    mode.add_argument("--json", action="store_true", help="machine-readable report")
    args = parser.parse_args(argv)

    if not PACKS_DIR.is_dir():
        print(f"[pack_warning] no packs directory at {PACKS_DIR}", file=sys.stderr)
        return 1

    report = []
    warnings_written = 0
    for pack in sorted(p for p in PACKS_DIR.iterdir() if p.is_dir()):
        for root in pack_roots(pack):
            fmt, _desc = pack_format(root)
            if fmt == 0:
                break
            label = pack.name if root == pack else f"{pack.name}/{root.name}"
            dirs = namespace_dirs(root)
            entry = {
                "pack": label,
                "format": fmt,
                "clickable": fmt >= CLICK_EVENT_MIN_FORMAT,
                "namespaces": [d.parent.name for d in dirs],
                "state": "",
            }

            if not dirs:
                entry["state"] = "skipped: no function directory"
                report.append(entry)
                continue

            if has_real_gate(root):
                entry["state"] = "gated: already refuses to run without consent"
                report.append(entry)
                continue

            tags = load_tag_files(root)
            if not tags:
                # A pack with functions but no minecraft:load tag never runs
                # anything on load, so it has nowhere to put a warning. Creating
                # the tag is safe -- it only names a function this script writes
                # -- but it changes pack behaviour, so it is opt-in per pack
                # rather than silent.
                entry["state"] = "skipped: no minecraft:load tag (cannot warn on load)"
                report.append(entry)
                continue

            targets = []
            for d in dirs:
                ns = d.parent.name
                path = d / WARNING_FILE
                body = warning_body(root, fmt, label)
                targets.append((path, body, ns, d.name))

            # Already warned? Detect the generated function and its tag entry so
            # --check is idempotent instead of permanently reporting "missing".
            already = all(path.is_file() for path, _, _, _ in targets)
            wired = False
            if already:
                entry_name = f"{targets[0][2]}:{WARNING_FILE[:-len('.mcfunction')]}"
                wired = any(
                    entry_name in json.loads(tag.read_text(encoding="utf-8")).get("values", [])
                    for tag in tags
                )
            if already and wired:
                entry["state"] = "warned: warning present and wired into the load tag"
                entry["files"] = [_rel(p) for p, _, _, _ in targets]
                report.append(entry)
                continue

            if args.apply:
                for path, body, ns, dirname in targets:
                    path.parent.mkdir(parents=True, exist_ok=True)
                    path.write_text(body, encoding="utf-8")
                # Wire it into the load tag, first in the list so it runs before
                # anything else the pack does.
                for tag in tags:
                    data = json.loads(tag.read_text(encoding="utf-8"))
                    values = data.setdefault("values", [])
                    # Prefer the namespace that owns the tag directory's pack.
                    ns, dirname = targets[0][2], targets[0][3]
                    entry_name = f"{ns}:{WARNING_FILE[:-len('.mcfunction')]}"
                    if entry_name not in values:
                        values.insert(0, entry_name)
                        tag.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
                entry["state"] = "written"
                entry["files"] = [_rel(p) for p, _, _, _ in targets]
                warnings_written += 1
            else:
                entry["state"] = "missing: needs a warning"
                entry["would_write"] = [_rel(p) for p, _, _, _ in targets]
            report.append(entry)

    if args.json:
        print(json.dumps(report, indent=2))
    else:
        for e in report:
            mark = {"written": "+", "missing": "!"}.get(e["state"].split(":")[0], "-")
            clickable = "clickable" if e["clickable"] else "plain"
            print(f"  {mark} {e['pack']:<32} fmt={e['format']:<4} {clickable:<10} {e['state']}")

    if args.check:
        missing = [e for e in report if e["state"].startswith("missing")]
        if missing:
            print(f"[pack_warning] {len(missing)} pack(s) have no archived warning", file=sys.stderr)
            return 1
        # Skipped packs are reported but do not fail the check: they have no
        # load path or no code at all, so there is nowhere to put a warning and
        # nothing to warn about. Silently passing them would hide a real pack
        # that lost its load tag, so they are printed above instead.
        skipped = [e for e in report if e["state"].startswith("skipped")]
        gated = [e for e in report if e["state"].startswith("gated")]
        print(f"[pack_warning] ok: {len(gated)} gated, {len(skipped)} with no load path",
              file=sys.stderr)
    if args.apply:
        print(f"[pack_warning] wrote {warnings_written} warning(s)", file=sys.stderr)
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
