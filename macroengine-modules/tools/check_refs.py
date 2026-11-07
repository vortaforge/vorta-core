"""Every id a pack names must exist somewhere in the split.

The rule this enforces is the one the server enforced, only earlier and with a
better error message: a `.mcfunction` or a registry JSON must not reference an id
that the split renamed into a namespace where nothing lives.

Why this test exists
--------------------
The split rewrites ids from the original `macroengine:` namespace into the
per-module `me_<module>_module:` namespaces. Ids it fails to recognise are left
pointing at `macroengine:...`, which after the split exists nowhere. The game says:

    Failed to load function me_core_module:gate/consent_dialog
    java.lang.IllegalArgumentException: Whilst parsing command on line 9:
    Can't find element 'macroengine:gate/warning' in registry 'minecraft:dialog'

Two rounds of this bug shipped. Each time the fix was a new pattern in
`REGISTRY_REF`, and each time the *next* one was found by booting a server. That
is the wrong loop: the set of places an id can appear is knowable, so it is
checked here instead.

Why it does not reuse `REGISTRY_REF`
------------------------------------
If this test asked `REGISTRY_REF` what to look for, it would pass whenever the
pattern was missing - which is exactly the failure it is meant to catch. So the
extractor below is deliberately independent and intentionally over-eager: it
matches *any* bare `namespace:path` token, whatever the surrounding command. The
false positives (storage ids, sound ids) are the price, and they are resolved
against what the pack actually defines rather than against the rewriter.

What a reference must resolve to
--------------------------------
- A **namespace the split owns** (`me_*_module`, `minecraft`) must be defined by
  some file in some pack, or be a tag, or be a namespace the game itself provides.
- The **old namespace** (`macroengine`) is never defined by the output, because
  the split moved everything out of it. Any occurrence in a non-comment line is a
  reference the split failed to rewrite.

`storage`, `sound`, `particle`, `item` and `attribute` ids are exempt: their
namespace is a user-chosen label with nothing in the pack behind it, so requiring
a definition would be wrong.
"""

from __future__ import annotations

import json
import pathlib
import re
import sys

# The namespace the source pack used, and which the split empties out.
OLD_NAMESPACE = "macroengine"
# A namespace written by the split, e.g. `me_core_module`.
NEW_NAMESPACE = re.compile(r"^me_[a-z0-9_]+_module$")

# A bare id, anywhere. Deliberately not anchored to a command: an id can be the
# target of `function`, the payload of `{func:"..."}`, the string in
# `data modify ... set value "..."`, an argument of `schedule clear`, or the last
# token of `advancement revoke @s only`.
ID_TOKEN = re.compile(r"(?<![\w:/.-])([a-z0-9_.-]+:[a-z0-9_/.-]+)")

# Command contexts where the following token is NOT a reference even though it
# looks like one. A storage id is a free-form label; sounds and particles are
# asset paths; `item <id>` in NBT is a component id.
# Anchored to the *end* of the text before the id (`$`): the exemption belongs to
# the id it introduces. Searching the whole line instead let one `storage ` early
# in a line exempt every later id on it, which silently hid two real bugs while
# this test reported OK.
EXEMPT_LEAD = re.compile(
    r"(?:\bstorage |\bsound |\bplaysound |\bparticle |\battribute |"
    r"\bcustom_data|\bitems? )$"
)
# The same ids appear as JSON keys in text components: `{"storage":"ns:name"}`.
# The lead is the key, not the command.
EXEMPT_KEY = re.compile(r'"(?:storage|sound|font)"\s*:\s*"$')

# An id that ends in `$` is built by a macro at runtime; its target cannot be
# known statically, and the split already reports those separately.
MACRO_ID = re.compile(r"[a-z0-9_/.-]+\$|<\$")

# Directories under `data/<ns>/` that define an id, keyed by the path prefix the
# id uses. `function/x/y.mcfunction` is the id `ns:x/y`; `tags/function/x.json`
# is the tag `#ns:x`.
ID_DIRS = ("advancement", "dialog", "function", "item_modifier", "loot_table",
           "predicate", "recipe")
TAG_DIRS = ("function", "item", "block", "entity", "fluid")


def defined_ids(packs: pathlib.Path) -> set[str]:
    """Every `namespace:path` id the split output actually defines."""
    out: set[str] = set()
    for data in packs.glob("*/data"):
        for ns_dir in data.iterdir():
            if not ns_dir.is_dir():
                continue
            ns = ns_dir.name
            for kind in ID_DIRS:
                root = ns_dir / kind
                if not root.is_dir():
                    continue
                for f in root.rglob("*"):
                    if f.is_file() and f.suffix in (".json", ".mcfunction"):
                        out.add(f"{ns}:{f.relative_to(root).with_suffix('').as_posix()}")
            tags = ns_dir / "tags"
            if tags.is_dir():
                for kind in TAG_DIRS:
                    root = tags / kind
                    if not root.is_dir():
                        continue
                    for f in root.rglob("*.json"):
                        out.add(f"{ns}:{f.relative_to(root).with_suffix('').as_posix()}")
    return out


def references(packs: pathlib.Path):
    """Yield (file, line number, line, id) for every candidate reference."""
    for f in sorted(packs.rglob("*")):
        if not f.is_file() or f.suffix not in (".mcfunction", ".json"):
            continue
        try:
            lines = f.read_text(encoding="utf-8").splitlines()
        except UnicodeDecodeError:
            continue
        for n, line in enumerate(lines, 1):
            # A comment is documentation. It is rewritten for readability, but it
            # is not resolved by the game, so it cannot break a boot.
            stripped = line.lstrip()
            if stripped.startswith("#"):
                continue
            for m in ID_TOKEN.finditer(line):
                before = line[:m.start()]
                # Skip anything introduced by a context that takes a free-form id.
                if EXEMPT_LEAD.search(before) or EXEMPT_KEY.search(before):
                    continue
                # An id *labelled* by a key - `{func:"ns:x"}`, `scores:{ns.y:1}` -
                # is still a real id unless it is the value of a free-form key.
                # `func` is the one the engine uses to name a function, so it is
                # deliberately not exempt.
                if MACRO_ID.search(before) or MACRO_ID.search(m.group(1)):
                    continue
                yield f, n, line, m.group(1)


def main() -> int:
    root = pathlib.Path(sys.argv[1] if len(sys.argv) > 1 else "packs")
    defined = defined_ids(root)
    problems: list[str] = []

    for f, n, line, ident in references(root):
        ns = ident.split(":", 1)[0]

        if ns == OLD_NAMESPACE:
            problems.append(
                f"{f.relative_to(root)}:{n}: '{ident}' was not rewritten and does "
                f"not exist in the output\n      {line.strip()[:140]}")
            continue
        if not NEW_NAMESPACE.match(ns):
            continue                      # minecraft:, or some other provided ns
        if ident in defined or ident.lstrip("#") in defined:
            continue
        # An id that ends in `/` is a directory, and only its namespace part is
        # checked: `me_cmd_module:api/cmd/$(type)` names whatever the macro picks
        # inside that directory, and the directory's existence is the thing that
        # can be wrong statically.
        if ident.endswith("/"):
            if any(ident.split(":", 1)[0] == d.split(":", 1)[0] for d in defined):
                continue
            problems.append(
                f"{f.relative_to(root)}:{n}: '{ident}' uses a namespace no pack defines\n"
                f"      {line.strip()[:140]}")
            continue
        problems.append(
            f"{f.relative_to(root)}:{n}: '{ident}' is not defined by any pack\n"
            f"      {line.strip()[:140]}")

    if problems:
        seen: set[str] = set()
        unique = [p for p in problems if not (p.split("\n")[0] in seen or seen.add(p.split("\n")[0]))]
        print(f"[check_refs] {len(unique)} unresolved id(s):")
        for p in unique[:40]:
            print("  - " + p)
        if len(unique) > 40:
            print(f"  ... and {len(unique) - 40} more")
        return 1

    print(f"[check_refs] OK: every id a pack names resolves - "
          f"{len(defined)} defined, no reference to the old namespace")
    return 0


if __name__ == "__main__":
    sys.exit(main())
