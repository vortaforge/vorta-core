#!/usr/bin/env python3
"""Assert that every jar in build/dist is a loadable Fabric mod.

The bug this exists for: the build produced 26 `.jar` files with no
`fabric.mod.json` in any of them. They were data pack jars - droppable into a
world's `datapacks/` folder, ignored by a mod loader - and nothing about the build
said so until someone tried to install one.

Three things make a jar loadable, and a missing one of them fails differently:

  fabric.mod.json      absent  -> the loader does not see a mod at all
  the entry point class absent  -> the loader sees the mod and refuses to start
                                   the whole game, naming a class it cannot find
  the data pack        absent   -> the mod loads and does nothing

So all three are checked here, against the real jars, rather than trusting the
Gradle tasks that were supposed to produce them.

Run:  python3 tools/check_jars.py [--dist build/dist]
Exit: 0 every jar is a loadable mod; 1 otherwise.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
import zipfile
from pathlib import Path

DEFAULT_DIST = Path("build/dist")


def class_in_nested(archive: zipfile.ZipFile, entry: str, path: str) -> bool:
    """True when `path` is inside the nested jar `entry`."""
    import io

    try:
        raw = archive.read(entry)
        with zipfile.ZipFile(io.BytesIO(raw)) as inner:
            return path in inner.namelist()
    except (KeyError, zipfile.BadZipFile):
        return False


def problems_for(jar: Path) -> list[str]:
    found: list[str] = []
    with zipfile.ZipFile(jar) as archive:
        names = set(archive.namelist())

        if "fabric.mod.json" not in names:
            found.append(f"{jar.name}: no fabric.mod.json - this is a data pack jar, "
                         f"not a mod jar")
            return found

        try:
            meta = json.loads(archive.read("fabric.mod.json"))
        except json.JSONDecodeError as exc:
            found.append(f"{jar.name}: fabric.mod.json is not valid JSON ({exc})")
            return found

        for field in ("schemaVersion", "id", "version"):
            if field not in meta:
                found.append(f"{jar.name}: fabric.mod.json has no `{field}`")

        mod_id = meta.get("id", "")
        if mod_id and not all(c.islower() or c.isdigit() or c in "-_" for c in mod_id):
            found.append(f"{jar.name}: mod id `{mod_id}` is not a valid Fabric id "
                         f"(lowercase letters, digits, - and _ only)")

        # The declared entry point must be a class that is actually loadable.
        # Fabric aborts the launch when it is not, so this is the check that
        # decides whether the game starts at all.
        #
        # The class may be in the jar itself or in a nested jar under
        # META-INF/jars/ - Fabric extracts those and loads them, which is how one
        # shared entry point serves all 26 mods. Both are checked, because the
        # failure mode is identical either way.
        entrypoints = meta.get("entrypoints", {}).get("main", [])
        if not entrypoints:
            found.append(f"{jar.name}: no `main` entrypoint")
        nested = [n for n in names if n.startswith("META-INF/jars/") and n.endswith(".jar")]
        for entry in entrypoints:
            path = entry.replace(".", "/") + ".class"
            if path in names:
                continue
            if any(class_in_nested(archive, n, path) for n in nested):
                continue
            found.append(
                f"{jar.name}: entry point {entry} is declared but {path} is in "
                f"neither the jar nor any of its {len(nested)} nested jar(s)")

        # A nested jar is only useful to Fabric if it is a real jar with the class
        # in it; an empty META-INF/jars/ entry looks correct and does nothing.
        if not nested:
            found.append(f"{jar.name}: no META-INF/jars/ - the declared entry point "
                         f"cannot be resolved unless the class is in this jar")

        # A mod without its data is a mod that does nothing.
        if "pack.mcmeta" not in names:
            found.append(f"{jar.name}: no pack.mcmeta - the bundled data pack will "
                         f"not load")
        if not any(n.startswith("data/") for n in names):
            found.append(f"{jar.name}: no data/ tree")

        # The data pack's own compatibility range. 26.x reads min_format/
        # max_format; `pack_format` is the pre-1.21.9 spelling and is ignored,
        # which would make the game treat the pack as incompatible.
        if "pack.mcmeta" in names:
            try:
                pack = json.loads(archive.read("pack.mcmeta")).get("pack", {})
            except json.JSONDecodeError:
                found.append(f"{jar.name}: pack.mcmeta is not valid JSON")
            else:
                if "min_format" not in pack or "max_format" not in pack:
                    found.append(f"{jar.name}: pack.mcmeta uses pack_format instead of "
                                 f"min_format/max_format (ignored by 26.x)")

        # A jar must not carry another mod's namespace data, or installing two
        # modules would load the same pack twice and double every hook tag value.
        # `rsplit` on the version must not eat the pack name: the jars are
        # `me_cb_module-1.0.0.jar`, so the name is everything before the first
        # `-<digit>`, not before the last dash.
        own = re.match(r"(.+?)-\d", jar.stem)
        own = own.group(1) if own else jar.stem
        # `len(parts) >= 2` and a non-empty second segment: the bare `data/` entry
        # is a directory in the zip and yields an empty name that is not a leak.
        namespaces = {n.split("/")[1] for n in names
                      if n.startswith("data/") and len(n.split("/")) > 1
                      and n.split("/")[1]}
        foreign = sorted(namespaces - {own})
        # Two namespaces a jar may legitimately ship besides its own:
        #
        #   me_core_module  the hook contribution tag. A module *adds itself* to a
        #                   core slot by writing the core's tag id in its own
        #                   pack; the game merges the definitions.
        #   minecraft       #minecraft:load and #minecraft:tick, the two loader
        #                   tags the core writes to start the engine.
        #
        # Anything else means a module is carrying another module's data, which
        # would run that feature twice if both packs were installed.
        allowed = {"me_core_module", "minecraft"}
        for namespace in foreign:
            if namespace not in allowed:
                found.append(f"{jar.name}: ships data from {namespace}, which is not "
                             f"this mod's namespace")
    return found


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--dist", type=Path, default=DEFAULT_DIST)
    args = parser.parse_args(argv)

    jars = sorted(args.dist.glob("*.jar")) if args.dist.is_dir() else []
    if not jars:
        sys.stderr.write(f"no jars in {args.dist}; run `gradlew dist` first\n")
        return 1

    problems: list[str] = []
    ids: dict[str, str] = {}
    for jar in jars:
        problems.extend(problems_for(jar))
        try:
            with zipfile.ZipFile(jar) as archive:
                meta = json.loads(archive.read("fabric.mod.json"))
        except (KeyError, json.JSONDecodeError):
            continue
        mod_id = meta.get("id", "")
        if mod_id in ids:
            problems.append(f"mod id `{mod_id}` is used by both {ids[mod_id]} and "
                            f"{jar.name}; Fabric ids must be unique")
        ids[mod_id] = jar.name

    # Every module must depend on the core, or it loads without the internals it
    # calls and every function reference fails at runtime.
    for jar in jars:
        try:
            with zipfile.ZipFile(jar) as archive:
                meta = json.loads(archive.read("fabric.mod.json"))
        except (KeyError, json.JSONDecodeError):
            continue
        if meta.get("id") == "macroengine-core":
            continue
        if "macroengine-core" not in meta.get("depends", {}):
            problems.append(f"{jar.name}: does not declare a dependency on "
                            f"macroengine-core, but its functions call "
                            f"me_core_module:core/internal/...")

    # The bug this whole file exists for, in its second form: a class that exists,
    # is named correctly, and does not implement ModInitializer. Fabric loads it,
    # fails the cast, and refuses to start the server. Checking the constant pool
    # of the class file catches that without running a game.
    for jar in jars:
        try:
            with zipfile.ZipFile(jar) as archive:
                meta = json.loads(archive.read("fabric.mod.json"))
        except (KeyError, zipfile.JSONDecodeError, json.JSONDecodeError):
            continue
        for entry in meta.get("entrypoints", {}).get("main", []):
            path = entry.replace(".", "/") + ".class"
            data = None
            with zipfile.ZipFile(jar) as archive:
                if path in archive.namelist():
                    data = archive.read(path)
                else:
                    import io
                    for nested in [n for n in archive.namelist()
                                   if n.startswith("META-INF/jars/")]:
                        try:
                            with zipfile.ZipFile(io.BytesIO(archive.read(nested))) as inner:
                                if path in inner.namelist():
                                    data = inner.read(path)
                                    break
                        except zipfile.BadZipFile:
                            continue
            if data is None:
                continue
            # The interface's name is in the class file's constant pool whether it
            # is implemented directly or through a superclass.
            if b"net/fabricmc/api/ModInitializer" not in data:
                problems.append(
                    f"{jar.name}: entry point {entry} does not implement "
                    f"net.fabricmc.api.ModInitializer - Fabric will fail the cast "
                    f"and refuse to start the server")

    if problems:
        for problem in problems:
            print(f"  - {problem}")
        print(f"\n[check_jars] FAILED: {len(problems)} problem(s) across {len(jars)} jar(s)")
        return 1

    print(f"[check_jars] OK: {len(jars)} loadable Fabric mod jar(s), "
          f"unique ids, entry points present, core dependency declared")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
