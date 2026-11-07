"""Proves `check_refs.py` catches the id shapes that broke real servers.

A checker that has never failed is not evidence. Each case below is an id form the
split has actually got wrong at some point - every one of them shipped a pack that
the game refused to load with `Can't find element ... in registry`, or a function
that silently did nothing. The test breaks a copy of the good tree in exactly that
way and asserts the checker reports it.

The cases come from the audit trail, not from imagination:

  * `"dialog": "ns:id"`      - a JSON key in a 26.x dialog; the registry refused
                               to freeze: "Unbound values ... minecraft:dialog".
  * `dialog show @s ns:id`   - the command form, not the JSON key.
  * `execute if predicate`   - the command form of a predicate reference.
  * `{func:"ns:id"}`         - an SNBT payload naming the next function to run.
  * `advancement revoke ... only ns:id` - the id is the last token, behind a
                               target selector and `only`.
  * `storage` / `playsound`  - NOT references. These must stay accepted, or the
                               checker is crying wolf and gets ignored.

Run: python3 tools/test_check_refs.py
"""

from __future__ import annotations

import json
import pathlib
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
GOOD = ROOT / "packs"
CHECKER = ROOT / "tools" / "check_refs.py"


def run(packs: pathlib.Path) -> tuple[int, str]:
    p = subprocess.run([sys.executable, str(CHECKER), str(packs)],
                       capture_output=True, text=True)
    return p.returncode, p.stdout + p.stderr


def edit(packs: pathlib.Path, rel: str, fn) -> None:
    path = packs / rel
    path.write_text(fn(path.read_text(encoding="utf-8")), encoding="utf-8")


CASES: list[tuple[str, callable]] = []


def case(name):
    def register(fn):
        CASES.append((name, fn))
        return fn
    return register


@case("a dialog JSON key pointing at the old namespace")
def _(packs: pathlib.Path) -> None:
    def fn(text):
        obj = json.loads(text)

        def walk(o):
            if isinstance(o, dict):
                for k, v in o.items():
                    if k == "dialog" and isinstance(v, str):
                        o[k] = "macroengine:gate/confirm"
                    else:
                        walk(v)
            elif isinstance(o, list):
                for x in o:
                    walk(x)
        walk(obj)
        return json.dumps(obj, indent=2)
    edit(packs, "me_core_module/data/me_core_module/dialog/gate/warning.json", fn)


@case("`dialog show` naming the old namespace")
def _(packs: pathlib.Path) -> None:
    edit(packs, "me_core_module/data/me_core_module/function/gate/consent_dialog.mcfunction",
         lambda t: t.replace("dialog show @s me_core_module:", "dialog show @s macroengine:"))


@case("`execute if predicate` naming the old namespace")
def _(packs: pathlib.Path) -> None:
    edit(packs, "me_world_module/data/me_world_module/function/world/weather.mcfunction",
         lambda t: t.replace("if predicate me_core_module:", "if predicate macroengine:"))


@case("an SNBT `{func:\"...\"}` payload naming the old namespace")
def _(packs: pathlib.Path) -> None:
    # `events/` moved to its own module, so the file is found rather than assumed:
    # this test is about the id shape, not about where the file lives.
    hits = sorted(packs.rglob("fire_queued.mcfunction"))
    if not hits:
        raise AssertionError("fire_queued.mcfunction is not in the output any more")
    hits[0].write_text(hits[0].read_text(encoding="utf-8").replace(
        '{func:"me_', '{func:"macroengine:'), encoding="utf-8")


@case("`advancement revoke ... only` naming the old namespace")
def _(packs: pathlib.Path) -> None:
    def fn(text):
        out = []
        for line in text.splitlines(keepends=True):
            if "advancement revoke" in line and " only " in line and " me_" in line:
                line = line.replace(" only me_", " only macroengine:")
            out.append(line)
        return "".join(out)
    edit(packs, "me_hook_module/data/me_hook_module/function/hook/on_trade.mcfunction", fn)


@case("a reference to an id that no pack defines")
def _(packs: pathlib.Path) -> None:
    def fn(text):
        return text + "\nexecute if predicate me_core_module:nope_it_does_not_exist run return 0\n"
    edit(packs, "me_world_module/data/me_world_module/function/world/weather.mcfunction", fn)


# The other half of the test: a checker that flags everything is useless.
# `func` names a real function, `storage`/`playsound` name free-form labels. All
# three must stay accepted.
NOT_BROKEN = [
    ("me_core_module/data/me_core_module/function/core/internal/core/lib/fiber/yield_exec.mcfunction",
     'data modify storage macroengine:engine queue append value '
     '{func:"me_core_module:core/internal/text/load", delay:1}'),
    ("me_core_module/data/me_core_module/function/core/internal/title/_apply.mcfunction",
     'title @s title {"storage":"macroengine:title","nbt":"t"}'),
    ("me_core_module/data/me_core_module/function/core/internal/cmd/freeze/apply.mcfunction",
     'playsound macroengine:ui.freeze master @s ~ ~ ~ 0.9 0.9'),
]


def main() -> int:
    if not GOOD.is_dir():
        print(f"no {GOOD} - run tools/split.py first", file=sys.stderr)
        return 2

    failures = 0

    code, out = run(GOOD)
    if code != 0:
        print("FAIL the unmodified tree should pass but did not:")
        print(out)
        failures += 1
    else:
        print("ok   the unmodified tree passes")

    for name, breaker in CASES:
        with tempfile.TemporaryDirectory() as tmp:
            copy = pathlib.Path(tmp) / "packs"
            shutil.copytree(GOOD, copy)
            breaker(copy)
            code, out = run(copy)
            if code == 0:
                print(f"FAIL {name}: checker reported OK on a broken pack")
                failures += 1
            else:
                print(f"ok   caught: {name}")

    # A free-form id next to nothing must not be reported: storage/sound ids are
    # labels, and a pack legitimately keeps them in the original namespace.
    with tempfile.TemporaryDirectory() as tmp:
        copy = pathlib.Path(tmp) / "packs"
        shutil.copytree(GOOD, copy)
        for rel, line in NOT_BROKEN:
            edit(copy, rel, lambda t, line=line: t + "\n" + line + "\n")
        code, out = run(copy)
        if code != 0:
            print("FAIL a storage/sound id was reported as a broken reference:")
            print(out)
            failures += 1
        else:
            print("ok   storage and sound ids are not treated as references")

    print()
    total = 1 + len(CASES) + 1
    print(f"{total - failures}/{total} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
