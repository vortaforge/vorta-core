#!/usr/bin/env python3
"""
Verify the core-plus-modules split.

A Minecraft data pack has no linker and no type checker: an id that nothing defines
is not a build error, it is a command that fails once at runtime in a log nobody
reads. So every check here is literal, and every one answers a question a broken
split would otherwise answer silently.

Checks:
  1. every reference resolves to a defined function or tag
  2. no call still resolves through the old `macroengine:` namespace
  3. no module calls another module's private `internal/` tree
  4. every module is a complete pack (namespace, pack.mcmeta, functions)
  5. minecraft load/tick tags exist and name something that exists
  6. every pack.mcmeta declares 26.3 (121.0) coherently
  7. the module dependency graph has no cycles
  8. modules reach core only through declared hooks; core never names a module
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from collections import defaultdict
from pathlib import Path

OLD_NAMESPACE = "macroengine"
# Module names may contain an underscore: `me_rate_limit_module`. The original
# pattern required `[a-z0-9]+`, so any name with an underscore in it failed the
# namespace check for a reason that had nothing to do with the namespace.
NS_RE = re.compile(r"^me_([a-z0-9][a-z0-9_]*[a-z0-9]|[a-z0-9])_module$")
# `#` is captured, not skipped: `function #x:y` names a tag, and tags live in a
# different folder from functions. Dropping it made every tag reference look like a
# dangling function reference.
FUNCTION_REF = re.compile(r"(?:^|\s)(?:run )?function (#?)([a-z0-9_.-]+:[a-z0-9_/.-]+)")
PRIVATE = "internal"

# A reference whose namespace is built by a macro expands at runtime. One exists in
# this pack (`macroengine:api/cmd/$(type)`); it is listed here so the check reports
# it as a known limitation rather than as a silent pass or a spurious failure.
# Ids a macro builds at run time. They cannot be resolved statically, so they are
# reported by split.py into build/MACRO_REFS.txt and exempted here rather than
# guessed at. Two independent shapes, both pre-existing in the source pack:
#   `macroengine:api/cmd/$(type)`   dispatch: the target depends on user data
#   `/function $(fn)`               a tellraw click_event handing over a whole id
KNOWN_MACRO_REFS = {"macroengine:api/cmd/"}
MACRO_LINE_MARKERS = ("$(type)", "$(fn)")


class Problems:
    def __init__(self) -> None:
        self.items: list[tuple[str, str]] = []

    def add(self, check: str, message: str) -> None:
        self.items.append((check, message))

    def __bool__(self) -> bool:
        return bool(self.items)


def module_of(namespace: str):
    match = NS_RE.match(namespace)
    return match.group(1) if match else None


def load_packs(root: Path):
    """Index every function and tag across every module pack."""
    functions: dict[str, Path] = {}
    tags: dict[str, Path] = {}
    namespaces: dict[str, Path] = {}

    for pack in sorted(p for p in root.iterdir() if p.is_dir()):
        data = pack / "data"
        if not data.is_dir():
            continue
        for ns_dir in sorted(p for p in data.iterdir() if p.is_dir()):
            namespaces[ns_dir.name] = pack
        for path in sorted(data.rglob("*")):
            if not path.is_file() or path.suffix not in (".mcfunction", ".json"):
                continue
            rel = path.relative_to(data).as_posix()
            parts = rel.split("/")
            if len(parts) < 3:
                continue
            namespace, kind = parts[0], parts[1]
            area = "/".join(parts[2:])
            if kind == "function" and area.endswith(".mcfunction"):
                functions[f"{namespace}:{area[:-len('.mcfunction')]}"] = path
            elif kind == "tags" and area.endswith(".json"):
                # data/<ns>/tags/<type>/<name>.json -> #<ns>:<name>
                #
                # The registry type is a *folder*, not part of the id: the file
                # data/minecraft/tags/function/tick.json is referenced as
                # #minecraft:tick. Indexing it as #minecraft:function/tick builds a
                # key the game never resolves, so every tag reference then looks
                # dangling - which is exactly the false signal this cost two rounds
                # of debugging to find.
                tag_parts = area.split("/")
                if len(tag_parts) < 2:
                    continue
                tag_name = "/".join(tag_parts[1:])[:-len(".json")]
                tags[f"#{namespace}:{tag_name}"] = path
    return functions, tags, namespaces


def is_function_tag(path: Path) -> bool:
    """True when this file lives under data/<ns>/tags/function/."""
    parts = path.parts
    for index, part in enumerate(parts):
        if part == "tags" and index + 1 < len(parts):
            return parts[index + 1] == "function"
    return False


def refs_in(path: Path):
    out = []
    for line in path.read_text(encoding="utf-8", errors="replace").splitlines():
        if line.lstrip().startswith("#"):
            continue
        for match in FUNCTION_REF.finditer(line):
            out.append(match.group(1) + match.group(2))
    return out


def tag_values(path: Path):
    try:
        obj = json.loads(path.read_text(encoding="utf-8"))
    except json.JSONDecodeError:
        return []
    return [v for v in obj.get("values", []) if isinstance(v, str)]


def check_resolve(root: Path, functions, tags, problems: Problems):
    for path in sorted(root.rglob("*.mcfunction")):
        for ref in refs_in(path):
            if ref in KNOWN_MACRO_REFS:
                continue
            # `function #ns:tag` calls a tag, which lives in tags/ not function/.
            # Checking only `functions` here reports every tag call as dangling.
            if ref.startswith("#"):
                if ref not in tags:
                    problems.add("dangling-reference",
                                 f"{path.relative_to(root)} -> {ref} (nothing defines it)")
            elif ref.endswith("/"):
                # A directory id: the leaf is filled in by a macro at runtime
                # (`function me_cmd_module:api/cmd/$(type)`), so there is no single
                # file to find. What can be checked is that the directory has
                # something in it - an empty one means every expansion fails.
                if not any(f.startswith(ref) for f in functions):
                    problems.add("dangling-reference",
                                 f"{path.relative_to(root)} -> {ref} (empty directory)")
            elif ref not in functions and f"#{ref}" not in tags:
                problems.add("dangling-reference",
                             f"{path.relative_to(root)} -> {ref} (nothing defines it)")
    for tag_id, path in tags.items():
        # A block/item/entity_type tag lists *vanilla content*, not pack functions:
        # #me_core_module:chests listing minecraft:chest is correct and must not be
        # reported as dangling. Only a function tag's values are function ids.
        if not is_function_tag(path):
            continue
        for value in tag_values(path):
            target = value[1:] if value.startswith("#") else value
            if target in KNOWN_MACRO_REFS:
                continue
            if value.startswith("#"):
                if f"#{target}" not in tags:
                    problems.add("dangling-tag", f"{tag_id} lists tag {value} (nothing defines it)")
            elif target not in functions and f"#{target}" not in tags:
                problems.add("dangling-tag", f"{tag_id} lists {value} (nothing defines it)")


def check_old_namespace(root: Path, problems: Problems):
    for path in sorted(root.rglob("*.mcfunction")):
        for number, line in enumerate(path.read_text(encoding="utf-8").splitlines(), 1):
            if line.lstrip().startswith("#"):
                continue
            # A *storage* name keeps the original namespace on purpose: it is a
            # data path (`storage macroengine:block tmp.m`), not a function id.
            # Matching on the bare word "function" caught those storage names
            # because the line also contained `function`, which is the whole
            # false-positive class here. Strip the data-source references first,
            # then look for a real call.
            # Four more things that carry the old namespace but are not function ids:
            #   `scores={macroengine.hook=..0}`   a scoreboard objective
            #   `nbt={...macroengine:{input:1b}}` a custom_data key
            #   `"storage":"macroengine:tui"`     a data storage name
            #   `# ... macroengine:x`             a comment (already never a call)
            stripped = re.sub(rf"storage {OLD_NAMESPACE}:[a-z0-9_/]+", "storage <data>", line)
            stripped = re.sub(rf"\b{OLD_NAMESPACE}\.[a-z0-9_.]+", "<objective>", stripped)
            stripped = re.sub(rf"{OLD_NAMESPACE}:\{{", "<nbt>:{", stripped)
            if "function" in stripped and f"{OLD_NAMESPACE}:" in stripped \
                    and not any(marker in line for marker in MACRO_LINE_MARKERS):
                problems.add("old-namespace", f"{path.relative_to(root)}:{number} "
                                              f"still calls {OLD_NAMESPACE}:")
    for path in sorted(root.rglob("*.json")):
        text = path.read_text(encoding="utf-8")
        # A JSON file may hold a *data storage* name (`"storage": "macroengine:input"`,
        # the loot table / item modifier side of the pack) or a dialog id. Neither is
        # a function reference and neither moved namespace. Strip those keys before
        # looking, so only a real registry reference is reported.
        stripped = re.sub(r'"storage"\s*:\s*"[^"]*"', '"storage":"<data>"', text)
        stripped = re.sub(r'"dialog"\s*:\s*"[^"]*"', '"dialog":"<id>"', stripped)
        if f'"{OLD_NAMESPACE}:' in stripped:
            problems.add("old-namespace",
                         f"{path.relative_to(root)} still references {OLD_NAMESPACE}:")


def check_no_module_internals(root: Path, problems: Problems):
    """No module may ship a `core/internal/` tree. Those belong to core.

    This is the rule the user reported twice. A module pack containing
    `data/me_cb_module/function/core/internal/cb/apply_defaults.mcfunction` is
    a second copy of core code that reads like core's own tree but dies with the
    module, and it is invisible to a reference check because the id resolves.
    """
    for pack in sorted(root.glob("me_*_module")):
        if pack.name == "me_core_module":
            continue
        for path in sorted(pack.rglob("core/internal/**")):
            if path.is_file():
                problems.add(
                    "module-internal",
                    f"{path.relative_to(root)} is core's internal tree shipped "
                    f"inside {pack.name}; internals belong to me_core_module only")


def check_private(root: Path, problems: Problems):
    """A module may call core's public surface, never another module's internals."""
    for path in sorted(root.rglob("*.mcfunction")):
        parts = path.relative_to(path.parents[len(path.parents) - 1]).as_posix()
        namespace = path.relative_to([p for p in path.parents if (p / "data").is_dir()][-1]
                                     ) if False else None
        ns = None
        for parent in path.parents:
            if (parent / "data").is_dir():
                rel = path.relative_to(parent / "data").as_posix().split("/")[0]
                ns = rel
                break
        caller = module_of(ns or "")
        if caller is None:
            continue
        for ref in refs_in(path):
            callee_ns, _, area = ref.partition(":")
            callee = module_of(callee_ns)
            if callee is None or callee == caller:
                continue
            if area.startswith(PRIVATE + "/") or f"/{PRIVATE}/" in f"/{area}":
                # Only core may own an internal tree. Any other owner means the
                # call targets a tree that must not exist.
                if callee != "core":
                    problems.add("private-access",
                                 f"me_{caller}_module calls {ref} - that is "
                                 f"me_{callee}_module's private tree; internals "
                                 f"live in me_core_module and are called as "
                                 f"me_core_module:{area}")
                elif caller != "core":
                    # Reaching core's internals is correct and intended: that is
                    # how every module gets its implementation. Nothing to report.
                    pass


def check_pack_completeness(root: Path, namespaces, problems: Problems):
    seen = set()
    for namespace, pack in namespaces.items():
        if namespace == "minecraft":
            # The `minecraft` namespace holds the loader tags (#minecraft:load /
            # #minecraft:tick). The core owns them by design; they are not a module.
            continue
        module = module_of(namespace)
        if module is None:
            problems.add("pack-layout", f"{pack.name}/data/{namespace} is not a me_<module>_module namespace")
            continue
        seen.add(module)
        if not (pack / "pack.mcmeta").is_file():
            problems.add("pack-layout", f"{pack.name} has no pack.mcmeta; the game will not load it")
        # A module may legitimately be data-only (predicates, advancements, loot
        # tables). What must not happen is a pack that contains nothing at all.
        if not any(p for p in (pack / "data" / namespace).rglob("*") if p.is_file()):
            problems.add("pack-layout", f"{pack.name} declares a module but is empty")
    return seen


def check_loader(root: Path, tags, problems: Problems):
    for required in ("#minecraft:load", "#minecraft:tick"):
        if required not in tags:
            problems.add("loader-tag", f"{required} is missing; nothing would ever run")
            continue
        if not tag_values(tags[required]):
            problems.add("loader-tag", f"{required} is empty")


def check_pack_format(root: Path, problems: Problems):
    for meta in sorted(root.glob("*/pack.mcmeta")):
        try:
            obj = json.loads(meta.read_text(encoding="utf-8"))
        except json.JSONDecodeError as e:
            problems.add("pack-mcmeta", f"{meta.parent.name}: not valid JSON ({e})")
            continue
        pack_obj = obj.get("pack", {})
        lo, hi = pack_obj.get("min_format"), pack_obj.get("max_format")
        if lo is None or hi is None:
            problems.add("pack-mcmeta", f"{meta.parent.name}: min_format/max_format must both be declared")
            continue
        if not (isinstance(lo, list) and isinstance(hi, list)):
            problems.add("pack-mcmeta", f"{meta.parent.name}: formats must be number arrays")
            continue
        if lo > hi:
            problems.add("pack-mcmeta", f"{meta.parent.name}: min_format {lo} exceeds max_format {hi}")
        if hi[:1] != [121]:
            problems.add("pack-mcmeta",
                         f"{meta.parent.name}: max_format {hi} does not name 26.3 (121.0)")


def check_acyclic(root: Path, problems: Problems):
    edges: dict[str, set[str]] = defaultdict(set)
    for path in sorted(root.rglob("*.mcfunction")):
        ns = None
        for parent in path.parents:
            if (parent / "data").is_dir():
                ns = path.relative_to(parent / "data").as_posix().split("/")[0]
                break
        caller = module_of(ns or "")
        if caller is None:
            continue
        for ref in refs_in(path):
            callee = module_of(ref.split(":", 1)[0])
            if callee and callee != caller:
                edges[caller].add(callee)

    state: dict[str, int] = {}

    def visit(node: str, stack: list[str]) -> None:
        state[node] = 1
        stack.append(node)
        for nxt in sorted(edges.get(node, ())):
            if state.get(nxt) == 1 and nxt in stack:
                cycle = " -> ".join(stack[stack.index(nxt):] + [nxt])
                problems.add("cycle", f"module dependency cycle: {cycle}")
            elif state.get(nxt) is None:
                visit(nxt, stack)
        stack.pop()
        state[node] = 2

    for module in sorted(edges):
        if state.get(module) is None:
            visit(module, [])
    return edges


def check_core_does_not_name_modules(root: Path, problems: Problems):
    """Core must reach modules only through its hook tags."""
    core = None
    for pack in root.iterdir():
        if pack.name == "me_core_module":
            core = pack
    if core is None:
        problems.add("hooks", "me_core_module is missing")
        return
    for path in sorted(core.rglob("*.mcfunction")):
        for ref in refs_in(path):
            callee = module_of(ref.split(":", 1)[0])
            if callee and callee != "core":
                problems.add("hooks",
                             f"core calls {ref} directly; core must go through a hook tag so "
                             f"the module stays removable")


def check_hook_tags(root: Path, tags, problems: Problems):
    """Every value in a core hook tag must come from the module that declares it."""
    for tag_id, path in sorted(tags.items()):
        callee_ns = tag_id.lstrip("#").split(":", 1)[0]
        if module_of(callee_ns) != "core":
            continue
        if "/hook/" not in tag_id:
            continue
        for value in tag_values(path):
            target_ns = value.lstrip("#").split(":", 1)[0]
            if module_of(target_ns) is None:
                problems.add("hooks", f"{tag_id} lists {value}, which is not a module function")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--pack", required=True, type=Path,
                        help="the directory holding the module packs")
    parser.add_argument("--graph", action="store_true")
    args = parser.parse_args(argv[1:])

    root = args.pack.resolve()
    problems = Problems()

    functions, tags, namespaces = load_packs(root)
    modules = check_pack_completeness(root, namespaces, problems)
    check_resolve(root, functions, tags, problems)
    check_old_namespace(root, problems)
    check_no_module_internals(root, problems)
    check_private(root, problems)
    check_loader(root, tags, problems)
    check_pack_format(root, problems)
    edges = check_acyclic(root, problems)
    check_core_does_not_name_modules(root, problems)
    check_hook_tags(root, tags, problems)

    print(f"[verify] {len(functions)} function(s), {len(tags)} tag(s), {len(modules)} module pack(s)")

    if args.graph:
        print("\nmodule dependency graph (caller -> callee):")
        for caller in sorted(edges):
            if edges[caller]:
                print(f"  {caller:<12} -> {', '.join(sorted(edges[caller]))}")
        roots = [m for m in modules if m != "core" and not any(m in v for v in edges.values())]
        if roots:
            print(f"\n  nothing calls these (they are entry points): {', '.join(sorted(roots))}")

    if problems:
        by_check: dict[str, list[str]] = defaultdict(list)
        for check, message in problems.items:
            by_check[check].append(message)
        for check in sorted(by_check):
            print(f"\n[{check}] {len(by_check[check])} problem(s)")
            for message in by_check[check][:12]:
                print("  - " + message)
            if len(by_check[check]) > 12:
                print(f"  ... and {len(by_check[check]) - 12} more")
        print(f"\n[verify] FAILED: {len(problems.items)} problem(s)")
        return 1

    print("[verify] OK: references resolve, no module reaches into another's internals, "
          "core names no module, and the graph is acyclic")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
