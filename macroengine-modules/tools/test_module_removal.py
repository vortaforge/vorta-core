"""Every module must be removable.

The point of splitting one data pack into 29 is that you can install the core and
the modules you want. That claim is only true if removing a module leaves the rest
loadable: no dangling reference, no call into a namespace that is no longer there.

This is easy to lose. A single `function me_events_module:events/fire` written into
another module makes two packs co-dependent, and nothing about the line looks wrong
until someone installs one without the other. That is exactly what happened when
`events/` became a module: the hook module still called it directly.

So, for every module: remove it, run `verify.py` over what remains, and fail if
anything dangles. This is slower than a lint and it is the check that matches what
a user actually does.

Run: python3 tools/test_module_removal.py [--keep <module> ...]
"""

from __future__ import annotations

import pathlib
import shutil
import subprocess
import sys
import tempfile

ROOT = pathlib.Path(__file__).resolve().parent.parent
PACKS = ROOT / "packs"
VERIFY = ROOT / "tools" / "verify.py"

# The core is not optional; removing it is not a scenario anyone installs. Every
# other pack is.
CORE = "me_core_module"


def verify(packs: pathlib.Path) -> tuple[int, str]:
    proc = subprocess.run([sys.executable, str(VERIFY), "--pack", str(packs)],
                          capture_output=True, text=True)
    return proc.returncode, proc.stdout + proc.stderr


def main() -> int:
    if not PACKS.is_dir():
        print(f"no {PACKS} - run tools/split.py first", file=sys.stderr)
        return 2

    modules = sorted(p.name for p in PACKS.iterdir()
                     if p.is_dir() and p.name != CORE)
    if not modules:
        print("no modules found", file=sys.stderr)
        return 2

    code, out = verify(PACKS)
    if code != 0:
        print("FAIL the complete tree does not verify, so removal proves nothing:")
        print(out)
        return 1
    print(f"ok   all {len(modules) + 1} packs together")

    failures = 0
    for module in modules:
        with tempfile.TemporaryDirectory() as tmp:
            copy = pathlib.Path(tmp) / "packs"
            shutil.copytree(PACKS, copy)
            shutil.rmtree(copy / module)
            code, out = verify(copy)
            if code != 0:
                print(f"FAIL without {module}: the remaining packs dangle")
                for line in out.splitlines():
                    if line.startswith("  - "):
                        print("       " + line.strip())
                failures += 1
            else:
                print(f"ok   without {module}")

    print()
    total = len(modules) + 1
    print(f"{total - failures}/{total} passed")
    return 1 if failures else 0


if __name__ == "__main__":
    sys.exit(main())
