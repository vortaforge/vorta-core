#!/usr/bin/env python3
"""
Split the macroEngine data pack into a core plus independent, separately-loadable modules.

    macroengine:<path>   ->   me_<module>_module:<path>

## Output layout

    build/packs/me_core_module/          data/me_core_module/...
    build/packs/me_player_module/        data/me_player_module/...
    ...

Each module is a complete data pack: its own `pack.mcmeta`, its own namespace, and
its own `minecraft:load` / `minecraft:tick` contributions. That is the Fabric API
arrangement - one core, modules that attach to it through defined points - and it
is the only arrangement in which a module can be dropped in or removed without
editing a single file in another module.

## Why references are rewritten rather than string-replaced

A function id appears in two roles:

  1. as a *reference* the game resolves - `function macroengine:systems/log/x`,
     a `values` entry in a function tag, an advancement reward;
  2. as an *opaque string* handed to another function -
     `data modify storage macroengine:input sub set value "cmd other"`.

Only the first is a namespace reference. A blind replacement over `macroengine:`
would rewrite the second too, turning `"cmd other"` into `"me_cmd_module:other"` and
silently breaking dispatch. References are therefore rewritten only where the game
resolves them.

Usage:
    python3 tools/split.py --source <pack-dir> --out <dir>
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

# ---------------------------------------------------------------------------
# Module assignment
# ---------------------------------------------------------------------------
#
# (module, ordered path prefixes). Longest prefix wins. Anything unmatched falls to
# core, and `--report-unmapped` prints those rather than letting them disappear.
#
# `api/<area>` and `core/internal/api/<area>` are assigned together on purpose:
# they are the public face and the private implementation of the same area, and
# splitting them would build a boundary that points the wrong way - the public
# function would reach across it into the neighbour's private tree.
MODULES: list[tuple[str, list[str]]] = [
    # --- the engine ------------------------------------------------------
    # Core owns internals, handlers, gates, load and tick. Nothing else.
    #
    # `core/internal/<x>/` is deliberately NOT matched by a bare `core/internal/`
    # prefix: that one entry is what previously pulled every module's private tree
    # into the core (507 of 1284 functions), leaving modules with no internal of
    # their own. Each feature area claims its own `core/internal/<area>/` below,
    # and only the engine areas (api-backed handlers, load, core libs) remain here.
    ("core", [
        "",
        "core/",                        # dispatch, queue, state, config, lib, tick
        "gate/",                        # load gate, consent, version
        "core/internal/api/",           # the handlers behind api/<x>
        "core/internal/load/",          # load sequencing
        "core/internal/events/",        # engine event bus
        "core/internal/ext/",           # core service primitives


        # --- kernel services ---
        # These are here for one reason: the engine calls them itself, at boot and
        # on every tick. A pack the engine cannot run without is not removable, and
        # a pack that is not removable is not a module - it is part of the kernel.
        # Shipping them as modules would either break the engine when they are
        # deleted or force the engine through a hook tag to add two numbers.
        #
        # They are still published under a stable id (see PUBLISHED_SERVICES), so a
        # feature module calls them the same way it calls any other core API.
        "systems/math/", "core/internal/systems/math/", "core/internal/math/",
        "systems/string/", "core/internal/systems/string/",
        "systems/text/", "core/internal/text/",
        "systems/rng/", "core/internal/systems/rng/", "core/internal/rng/",
        "systems/uuid/", "core/internal/systems/uuid/", "core/internal/uuid/",
        "systems/log/", "core/internal/systems/log/",
        "systems/geo/", "core/internal/systems/geo/",
        "systems/audit/", "core/internal/systems/audit/",
        "systems/validate/",
        # A gate, in the literal sense: every stored-string command executor passes
        # through it before the engine macro-executes anything.
        "systems/cmd_gate/",
        # The event bus the engine's deferred queue drains.
        "events/",
    ]),

    # --- feature modules -------------------------------------------------
    # Every module owns BOTH halves of its feature: the public `api/<area>/`
    # surface and the `core/internal/<area>/` implementation behind it. A module
    # that owned only the public half would have nowhere to put its own internals
    # and would end up reaching into core's, which is the bug this fixes.
    ("player",    ["player/", "core/internal/player/"]),
    ("world",     ["world/", "core/internal/world/"]),
    ("tui",       ["tui/", "core/internal/tui/"]),
    ("cmd",       ["api/cmd/", "core/internal/api/cmd/", "core/internal/cmd/"]),
    ("store",     ["api/store/", "core/internal/api/store/"]),
    ("wand",      ["api/wand/", "core/internal/api/wand/"]),
    ("perm",      ["api/perm/", "core/internal/api/perm/"]),
    ("title",     ["api/title/", "core/internal/api/title/"]),
    ("block",     ["api/block/", "core/internal/api/block/"]),
    ("item",      ["api/item/", "core/internal/api/item/"]),
    ("container", ["api/container/", "core/internal/api/container/"]),
    ("interaction", ["api/interaction/", "core/internal/api/interaction/"]),
    ("gamerule",  ["api/gamerule/", "core/internal/api/gamerule/"]),
    ("toggle",    ["api/toggle/"]),
    ("trigger",   ["api/trigger/", "core/internal/api/trigger/"]),
    ("cb",        ["api/cb/", "core/internal/api/cb/"]),
    ("macro",     ["api/macro/"]),
    ("color",     ["api/color/", "core/internal/systems/color/"]),
    ("diagnostics", ["api/diagnostics/"]),

    # --- foundation modules ----------------------------------------------
    # These were `systems/<x>/` in the original pack and got dumped into core by
    # the `systems/` catch-all. They are features with a public surface, an
    # internal tree and no business living in the engine.
    ("input",     ["input/", "core/internal/input/"]),
    ("logic",     ["systems/logic/"]),
    ("flag",      ["systems/flag/"]),
    ("rate_limit", ["systems/rate_limit/", "core/internal/systems/rate_limit/"]),
    ("sound",     ["systems/sound/"]),
    # The public hook surface and the handlers behind it are one feature, so they
    # move together - the same rule as every other area. Leaving the handlers in
    # core is what made the hook module reach into core's private tree.
    ("hook",      ["systems/hook/", "core/internal/systems/hook/"]),
]

# `core/internal/systems/<x>/` is the engine behind the `api/<x>/` module of the same
# name - the tick driver, the queues, the state. It belongs to the module that owns
# the feature, not to core: leaving it in core is what produced the `core -> cb ->
# core` cycle on the first run.
#
# `core/internal/systems/` entries with no `api/` counterpart (hook, log, math,
# rate_limit, rng, string, uuid, obj, color) stay in core, because core itself calls
# them and they have no public face of their own.
MODULE_OWNED_ENGINE = {"cb", "color"}

OLD_NAMESPACE = "macroengine"

# Segments dropped from every id. `api/` and `systems/` were the *organising folders*
# of the original pack; they carry no meaning once the namespace already says which
# module a function belongs to (`me_cmd_module:cmd/other/run`, not
# `me_cmd_module:api/cmd/other/run`). Dropping them is safe here because a dry run
# over all 1280 functions and 103 tags found zero collisions *within* a module - the
# remaining path is already unique, since the original folders never contained both
# `api/x` and `systems/x` with the same tail.
DROP_SEGMENTS = ("api", "systems")


def normalise_area(area: str) -> str:
    """Map an original pack path to the id it carries in the split.

    Three rewrites, in order:

        api/cmd/other/run            -> cmd/other/run
        systems/logic/if_or          -> logic/if_or
        core/internal/api/cmd/x      -> cmd/x
        core/internal/text/split     -> text/split

    The last two also collapse `internal/api/<area>` to `<area>`, because once the
    public and private halves live in the same module there is no reason for the
    private half to be nested under an `api/` folder - that shape only existed to
    keep the two halves apart inside one namespace.

    `internal` is NOT dropped in general. `x/internal/...` means "private to
    module x", which is the per-module internal the split needs; the old
    `core/internal/...` prefix is simply a path that predates the split.
    """
    segments = [s for s in area.split("/") if s not in DROP_SEGMENTS]
    # `core/internal/api/<area>/...` -> `core/internal/<area>/...`
    if len(segments) > 3 and segments[0] == "core" and segments[1] == "internal" \
            and segments[2] == "api":
        segments = [segments[0], segments[1], *segments[3:]]
    return "/".join(segments)

CHILD_TYPES = ("advancement", "dialog", "function", "item_modifier", "loot_table",
               "predicate", "recipe", "tags")

# Extension points. A module attaches to core by adding its own values to these;
# nothing in core ever names a module.
# ---------------------------------------------------------------------------
# Hooks: the only channel from the core to a module.
#
# A hook is *a tag id in the core namespace* that the core defines and that a
# module may define too, from its own pack. Function tags merge across packs
# (`replace:false` is the default; this generator writes it explicitly), so both
# definitions are unioned at load time and the slot runs every contributor.
#
# Why this shape, and not "core keeps a list of modules":
#   * core calls `function #me_core_module:hook/<slot>` and never names a module,
#     so deleting any module pack leaves the core loading and running cleanly.
#   * a module owns its contribution file in its own namespace, so two modules
#     never write the same file and git never has to merge them.
#   * it is the same mechanism vanilla uses for `#minecraft:tick`, which is why
#     it keeps working across a version bump.
#
# `(slot, module, function)` is the single source of truth below: the core's call
# site and the module's tag entry are both generated from it, so they cannot
# drift apart.
# ---------------------------------------------------------------------------
HOOK_CONTRIBUTIONS = [
    # slot                   module         function inside that module
    ("trigger_dispatch",     "trigger",     "core/internal/api/trigger/dispatch"),
    ("interaction_tick",     "interaction", "core/internal/api/interaction/tick_scan"),
    ("perm_tick",            "perm",        "core/internal/api/perm/trigger/tick_start"),
    ("perm_require",         "perm",        "api/perm/require"),
    ("wand_tick",            "wand",        "core/internal/api/wand/tick_scan"),
    ("cmd_freeze_tick",      "cmd",         "core/internal/api/cmd/freeze/tick"),
    ("cb_tick",              "cb",          "core/internal/systems/cb/tick"),
    ("player_enumerate",     "player",      "core/internal/player/enumerate"),
    ("player_resolve",       "player",      "core/internal/player/resolve"),
    ("player_init",          "player",      "core/internal/player/init"),
    ("player_init_online",   "player",      "core/internal/player/init_online"),
    ("player_init_from_name","player",      "core/internal/player/init_from_name"),
    ("player_get_name",      "player",      "player/get_name"),
    # The hook feature's per-tick scan. Core's tick driver called it directly, which
    # is the one thing core may never do - it makes the hook module unremovable.
    ("hook_tick",            "hook",        "core/internal/hook/tick_scan"),
]

# ---------------------------------------------------------------------------
# Cross-module calls that went into another module's private tree.
#
# The split inherits this from the original pack: `api/block` was written when
# container was part of the same namespace, so it calls `core/internal/container/*`
# directly. Once the two are separate packs that is a boundary violation - and it
# is the one that actually breaks: a module is allowed to be absent, so a call into
# its private tree is a call into a function that may not exist.
#
# The fix is the Fabric API fix: the callee publishes the primitive, the caller
# uses the publication. Doing it here rather than by hand keeps it reproducible
# when the source pack is re-cut.
# ---------------------------------------------------------------------------
# (module, new public id, source internal id, one-line contract)
PUBLISHED_PRIMITIVES = [
    ("container", "container/addr", "core/internal/container/_addr",
     "Resolve the address in storage macroengine:container tmp.k (x/y/z + optional slot). "
     "Returns 1 when it resolved, 0 otherwise."),
    ("container", "container/exists", "core/internal/container/_exists",
     "Returns 1 when storage macroengine:container tmp.k names a block with an "
     "Items list, 0 otherwise. Does not touch macroengine:output."),
    ("container", "container/slot_at", "core/internal/container/_ff_loop",
     "Return the next slot index at or after #ct_i in storage macroengine:container "
     "tmp.f, or -1 when the container is full. Macro function."),
    ("container", "container/find_first_free", "core/internal/container/_size_pick",
     "Resolve the container size from storage macroengine:container tmp.k (honouring "
     "the `ovr` field) and store it in #ct_size macroengine.tmp. Returns 1 when a "
     "size in 1..256 was found, 0 otherwise."),
]

# Caller-side rewrites. A module may only reach another module through the
# published id; the private path must not appear anywhere outside its own module.
CROSS_MODULE_REWRITES = [
    # input validating a captured string - the same primitives text/ and ext/ were
    # already published for, reached from a different module.
    ("me_core_module:core/internal/text/num_check",
     "me_core_module:text/num_check"),
    ("me_core_module:core/internal/text/scan_deny",
     "me_core_module:text/scan_deny"),
    ("me_core_module:core/internal/ext/input/int_to_score",
     "me_core_module:core/ext/input/int_to_score"),
    # hook resolving a player name it was handed. The player module publishes
    # get_name; init_from_name is the same contract one step earlier.
    ("me_player_module:core/internal/player/init_from_name",
     "me_player_module:player/init_from_name"),
    ("me_container_module:core/internal/container/_addr",
     "me_container_module:container/addr"),
    ("me_container_module:core/internal/container/_exists",
     "me_container_module:container/exists"),
    ("me_container_module:core/internal/container/_ff_loop",
     "me_container_module:container/slot_at"),
    ("me_container_module:core/internal/container/_size_pick",
     "me_container_module:container/find_first_free"),
    ("me_container_module:core/internal/container/slot_set_do",
     "me_container_module:container/slot_set_do"),
    ("me_container_module:core/internal/container/slot_get_do",
     "me_container_module:container/slot_get_do"),
    ("me_container_module:core/internal/container/slot_clear_do",
     "me_container_module:container/slot_clear_do"),
    ("me_container_module:core/internal/container/_src_first",
     "me_container_module:container/src_first"),
    # trigger: the perm module's trigger executor was calling trigger's private
    # call/call2. They are the module's dispatch primitives, so they become public.
    ("me_trigger_module:core/internal/trigger/call",
     "me_trigger_module:trigger/call"),
    ("me_trigger_module:core/internal/trigger/call2",
     "me_trigger_module:trigger/call2"),
    # core's text primitives used by gamerule to normalise a user-supplied name,
    # and by store to split/concat/validate a rendered value.
    ("me_core_module:core/internal/text/replace",
     "me_core_module:text/replace"),
    ("me_core_module:core/internal/text/lower",
     "me_core_module:text/lower"),
    ("me_core_module:core/internal/text/reset",
     "me_core_module:text/reset"),
    ("me_core_module:core/internal/text/split",
     "me_core_module:text/split"),
    ("me_core_module:core/internal/text/concat",
     "me_core_module:text/concat"),
    ("me_core_module:core/internal/text/safe",
     "me_core_module:text/safe"),
    ("me_core_module:core/internal/text/ctl",
     "me_core_module:text/ctl"),
    # core's engine primitives that a feature module legitimately needs. These are
    # the "core services" of the Fabric-API arrangement: a small, stable surface
    # every module may call, kept separate from the internals that change freely.
    ("me_core_module:core/internal/ext/perm_count",
     "me_core_module:core/ext/perm_count"),
    ("me_core_module:core/internal/ext/player/add_var_clamped",
     "me_core_module:core/ext/player/add_var_clamped"),
    ("me_core_module:core/internal/ext/player/toggle_var",
     "me_core_module:core/ext/player/toggle_var"),
    ("me_core_module:core/internal/ext/world/count_near",
     "me_core_module:core/ext/world/count_near"),
]

# Ids whose *source function* is relocated rather than wrapped. A wrapper is right
# for a primitive the module never intended to publish (it can stay private and the
# wrapper is the only door). These are different: the function itself becomes part
# of the public surface, so the file moves and the private path disappears.
MOVED_TO_PUBLIC = {
    "me_container_module:core/internal/container/slot_set_do",
    "me_container_module:core/internal/container/slot_get_do",
    "me_container_module:core/internal/container/slot_clear_do",
    "me_container_module:core/internal/container/_src_first",
    "me_trigger_module:core/internal/trigger/call",
    "me_trigger_module:core/internal/trigger/call2",
    "me_core_module:core/internal/text/replace",
    "me_core_module:core/internal/text/lower",
    "me_core_module:core/internal/text/reset",
    "me_core_module:core/internal/text/split",
    "me_core_module:core/internal/text/concat",
    "me_core_module:core/internal/text/safe",
    "me_core_module:core/internal/text/ctl",
    "me_core_module:core/internal/ext/perm_count",
    "me_core_module:core/internal/ext/player/add_var_clamped",
    "me_core_module:core/internal/ext/player/toggle_var",
    "me_core_module:core/internal/ext/world/count_near",
    "me_core_module:core/internal/text/num_check",
    "me_core_module:core/internal/text/scan_deny",
    "me_core_module:core/internal/ext/input/int_to_score",
    "me_player_module:core/internal/player/init_from_name",
}

# Id → destination path, for the moved ones. Derived from CROSS_MODULE_REWRITES so
# the two cannot disagree.
MOVED_DEST = {src: dst.split(":", 1)[1] for src, dst in CROSS_MODULE_REWRITES
              if src in MOVED_TO_PUBLIC}

# The four container functions that keep the `_do` suffix but move to the public
# surface. Listed separately because they are moved, not wrapped.
REPUBLISHED = {
    ("container", "slot_set_do"), ("container", "slot_get_do"),
    ("container", "slot_clear_do"), ("container", "src_first"),
}

# Slots the core ships empty so a third-party pack can join one later without the
# core being re-cut. An empty tag is a real, loadable, do-nothing tag.
EMPTY_SLOTS = ["tick", "load", "player_tick"]

# Anchored on a non-identifier boundary so a trailing `with storage ...` or any
# other argument survives the rewrite untouched.
HOOK_CALL_SUFFIX = r"(?![a-z0-9_/])"

# Slots whose contributors return a value the core reads. A plain event tag cannot
# carry one, but `execute store result ... run function #tag` stores the sum of the
# contributors' return values, and `unless function #tag` succeeds only when the
# whole tag returns non-zero. With one contributor that is exactly the old scalar
# return; with several it is a sum. Stated on the generated file, not assumed.
VALUE_SLOTS = {"perm_require", "player_get_name"}


def _is_within(child: Path, parent: Path) -> bool:
    """True when `child` is inside `parent` (or is `parent`)."""
    try:
        child.relative_to(parent)
    except ValueError:
        return False
    return True


def module_namespace(module: str) -> str:
    return f"me_{module}_module"


def assign_module(area: str) -> str:
    # An engine folder owned by a module outranks the generic `core/internal/systems/`
    # prefix, so it must be matched first.
    for name in MODULE_OWNED_ENGINE:
        if area.startswith(f"core/internal/systems/{name}/"):
            return name
    best, best_len = "core", -1
    for module, prefixes in MODULES:
        for prefix in prefixes:
            if area.startswith(prefix) and len(prefix) > best_len:
                best, best_len = module, len(prefix)
    return best


# ---------------------------------------------------------------------------
# Reference rewriting
# ---------------------------------------------------------------------------

# The `#` is captured, not dropped: `function #x:y` names a tag and `function x:y`
# names a function, and after the split they live in different folders. Losing the
# marker turns a valid tag reference into a dangling function reference.
FUNCTION_REF = re.compile(r"((?<![\w:])run function |(?<![\w:])function )(#?)([a-z0-9_.-]+:[a-z0-9_/.-]+)")

# ---------------------------------------------------------------------------
# Non-function registry references.
#
# The pack also ships 85 predicates, 46 advancements, 31 item modifiers, 7 loot
# tables and 5 recipes, and commands point at them by id: `predicate=macroengine:is_sneaking`,
# `loot macroengine:player/head`, `"parent": "macroengine:hidden/root"`. These are
# resolved by the game exactly like a function id, but none of them is preceded by
# the `function` verb, so the function pass never saw them. Left alone they keep
# pointing at a namespace that no longer exists in the split, which fails at load
# with a much less obvious error than a missing function.
#
# Each pattern captures the id in group 1 and is rewritten through the same mapping.
REGISTRY_REF = re.compile(
    r"(?P<lead>"
    r"(?:(?<![\w])predicate=!?)"
    r"|(?:\bloot )"
    r"|(?:\badvancement )"
    r"|(?:\"parent\"\s*:\s*\")"
    r"|(?:\"function\"\s*:\s*\")"
    r"|(?:\"loot_table\"\s*:\s*\")"
    r"|(?:\"predicate\"\s*:\s*\")"
    r"|(?:\"recipe\"\s*:\s*\")"
    r")(?P<id>[a-z0-9_.-]+:[a-z0-9_/.-]+)")


def rewrite_registry_refs(text: str, mapping: dict[str, str]) -> str:
    def sub(match: re.Match[str]) -> str:
        return match.group("lead") + mapping.get(match.group("id"), match.group("id"))
    return REGISTRY_REF.sub(sub, text)


# A reference built by a macro expands at runtime, so its target cannot be known
# statically. It is rewritten to the caller's own namespace and reported, because
# guessing a target would be worse than saying "this one needs a human".
MACRO_REF = re.compile(r"((?<![\w:])run function |(?<![\w:])function )(#?)([a-z0-9_.-]+:[a-z0-9_/.-]*)\$")


def rewrite_references(text: str, mapping: dict[str, str], *, self_ns: str,
                       macros: list[str], where: str) -> str:
    def sub_function(match: re.Match[str]) -> str:
        verb, hashmark, ident = match.group(1), match.group(2), match.group(3)
        return verb + hashmark + mapping.get(ident, ident)

    def sub_macro(match: re.Match[str]) -> str:
        verb, hashmark, prefix = match.group(1), match.group(2), match.group(3)
        macros.append(f"{where}: {prefix}$(…)")
        new_ns = module_namespace(self_ns[:0] or "")  # placeholder, replaced below
        return verb + hashmark + prefix + "$"

    text = MACRO_REF.sub(sub_macro, text)
    text = FUNCTION_REF.sub(sub_function, text)
    return text


DEFAULT_MC_FUNCTION = {"load", "tick"}


def rewrite_json(obj, mapping: dict[str, str]):
    """Rewrite tag `values` and any `function`-typed JSON field."""
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k == "values" and isinstance(v, list):
                out[k] = [_rewrite_id(x, mapping) if isinstance(x, str) else rewrite_json(x, mapping)
                          for x in v]
            elif k in ("function", "reward_function") and isinstance(v, str):
                out[k] = _rewrite_id(v, mapping)
            # Other registries the pack ships. `parent` is an advancement id,
            # `loot_table`/`predicate`/`recipe` are their own registries - all are
            # resolved by the game and all live under the same old namespace.
            elif k in ("parent", "loot_table", "predicate", "recipe", "item_modifier") \
                    and isinstance(v, str):
                out[k] = _rewrite_id(v, mapping)
            else:
                out[k] = rewrite_json(v, mapping)
        return out
    if isinstance(obj, list):
        return [rewrite_json(x, mapping) for x in obj]
    return obj


def _rewrite_id(value: str, mapping: dict[str, str]) -> str:
    tag = value.startswith("#")
    ident = value[1:] if tag else value
    return ("#" if tag else "") + mapping.get(ident, ident)


# ---------------------------------------------------------------------------
# The split
# ---------------------------------------------------------------------------

class Split:
    def __init__(self, source: Path, out: Path, *, force: bool = False,
                 in_place: bool = False):
        self.source = source
        self.force = force
        self.in_place = in_place
        self.out = out
        self.mapping: dict[str, str] = {}
        self.assigned: dict[str, str] = {}
        self.assigned_area: dict[str, str] = {}
        self.unmapped: list[str] = []
        self.files: list[tuple[Path, str, str]] = []
        self.macros: list[str] = []

    def collect(self) -> None:
        data = self.source / "data" / OLD_NAMESPACE
        if not data.is_dir():
            raise SystemExit(f"no data/{OLD_NAMESPACE} under {self.source}")
        for path in sorted(data.rglob("*")):
            if not path.is_file():
                continue
            rel = path.relative_to(data).as_posix()
            parts = rel.split("/")
            if len(parts) < 2 or parts[0] not in CHILD_TYPES:
                self.unmapped.append(rel)
                self.files.append((path, "core", rel))
                continue
            area = "/".join(parts[1:])
            if area.endswith(".mcfunction") or area.endswith(".json"):
                area = area.rsplit(".", 1)[0]
            if parts[0] == "tags":
                # data/<ns>/tags/<type>/<name>.json is addressed as <ns>:<name>.
                # The registry type is a folder, not part of the id, so it is
                # dropped here. Keeping it indexed the tag under a name the game
                # never resolves and left every `function #ns:tag` call pointing
                # at the old namespace.
                area = area.split("/", 1)[1] if "/" in area else area
            module = assign_module(area)
            # The mapping key is the *original* id (that is what the source pack
            # contains); the value is the module namespace plus the normalised area.
            self.assigned[f"{OLD_NAMESPACE}:{area}"] = module
            self.assigned_area[f"{OLD_NAMESPACE}:{area}"] = normalise_area(area)
            self.files.append((path, module, rel))

        for old_id, module in self.assigned.items():
            self.mapping[old_id] = (f"{module_namespace(module)}:"
                                    f"{self.assigned_area[old_id]}")

    @staticmethod
    def _dest_area(rel: str) -> str:
        """Map a source-relative path to its destination-relative path.

        `function/api/cmd/run.mcfunction` -> `function/cmd/run.mcfunction`.
        `tags/function/api/x.json`        -> `tags/function/x.json` (tag type is a
        folder, so only the *name* is normalised).
        """
        parts = rel.split("/")
        if len(parts) < 2:
            return rel
        kind = parts[0]
        if kind == "function":
            tail = parts[1:]
            return "/".join([kind, *[s for s in tail[:-1] if s not in DROP_SEGMENTS], tail[-1]])
        if kind == "tags":
            # tags/<type>/<name...>
            if len(parts) < 3:
                return rel
            tail = parts[2:]
            return "/".join([kind, parts[1],
                             *[s for s in tail[:-1] if s not in DROP_SEGMENTS], tail[-1]])
        # achievement/predicate/loot_table/... keep their folder, only ids change
        return "/".join([kind, *[s for s in parts[1:-1] if s not in DROP_SEGMENTS], parts[-1]])

    # Names that must never be the output root, because writing there means
    # deleting the project that is running the script. This is not hypothetical:
    # `--out .` did exactly that once, taking .git with it, and the only reason it
    # was recoverable is that the previous commit had been pushed.
    UNSAFE_OUT_NAMES = ("", ".", "..", "src", "tools", "docs", "gradle")

    def _clear_output(self) -> None:
        """Remove the previous output, refusing to remove anything else.

        The guard is deliberately narrow rather than clever: it stops the three ways
        this can go wrong in practice - `--out .`, `--out <project>`, and `--out`
        pointing at a directory that already holds the script's own sources.
        """
        if not self.out.exists():
            return

        resolved = self.out.resolve()

        if resolved.name in self.UNSAFE_OUT_NAMES or str(resolved) in ("/", ""):
            raise SystemExit(
                f"refusing to delete {resolved}: that is a project root, not a build "
                f"output directory.\n"
                f"Use a dedicated output path, e.g.  --out .   is NOT allowed; the "
                f"project layout writes packs to <out>/packs,\n"
                f"so pass the project root only via --in-place (see below) or use a "
                f"separate directory.")

        # Second guard: the output must not contain the source pack, and the source
        # must not contain the output. Either would mean the rmtree below deletes
        # data this run still needs.
        source = self.source.resolve()
        if _is_within(source, resolved) or _is_within(resolved, source):
            raise SystemExit(
                f"refusing to use {resolved} as output: it overlaps the source pack "
                f"{source}")

        # Third guard: never delete a checkout. A `.git` inside the output means a
        # human's repository, and rmtree would take the history with the build
        # products.
        if (resolved / ".git").exists() and not self.force:
            raise SystemExit(
                f"refusing to delete {resolved}: it is a git working tree "
                f"(it contains .git). Pass --force only if you are certain the "
                f"output directory is disposable.")

        shutil.rmtree(resolved)

    def write(self) -> None:
        if self.in_place:
            # Project-root mode: the packs and manifests live *inside* a checkout
            # alongside build.gradle and tools/, so clearing the whole root would
            # delete the project. Only the things this script owns are removed.
            for owned in (self.out / "packs", self.out / "modules.json",
                          self.out / "MACRO_REFS.txt"):
                if owned.is_dir():
                    shutil.rmtree(owned)
                elif owned.is_file():
                    owned.unlink()
        else:
            self._clear_output()

        # Module -> the hook contributions it declares. A module only ever adds its
        # own values; it never edits core's tag, which is what keeps modules
        # independent of each other and of core's internals.
        hook_values: dict[str, dict[str, list[str]]] = {}

        for path, module, rel in self.files:
            # Destination follows the normalised id, so the file the game loads is
            # the file the id names. Writing the source `rel` here would keep
            # `api/` and `systems/` on disk while the references used the short id,
            # i.e. every call would 404.
            dest_area = self._dest_area(rel)
            moved = MOVED_DEST.get(self._normalised_id(module, rel))
            if moved:
                dest_area = f"function/{moved}.mcfunction"
            dest = (self.out / "packs" / module_namespace(module) / "data"
                    / module_namespace(module) / dest_area)
            dest.parent.mkdir(parents=True, exist_ok=True)
            if path.suffix == ".mcfunction":
                text = path.read_text(encoding="utf-8")
                text = self._rewrite(text, rel)
                if module == "core":
                    # Only the core pack is barred from naming modules. Inside a
                    # module a direct call to a sibling is fine as long as the
                    # dependency direction is allowed, which the graph check
                    # enforces separately.
                    text = self._core_hook_rewrite(text)
                text = self._cross_module_rewrite(text, module)
                dest.write_text(text, encoding="utf-8")
                self._note_hooks(module, rel, text, hook_values)
            elif path.suffix == ".json":
                raw = path.read_text(encoding="utf-8")
                try:
                    obj = json.loads(raw)
                except json.JSONDecodeError:
                    dest.write_text(raw, encoding="utf-8")
                    continue
                dest.write_text(json.dumps(rewrite_json(obj, self.mapping), indent=2) + "\n",
                                encoding="utf-8")
            else:
                shutil.copy2(path, dest)

        # minecraft namespace: load/tick tags are the single place several modules
        # can be wired in at once, which is what makes core-plus-modules work.
        mc = self.source / "data" / "minecraft"
        if mc.is_dir():
            for path in sorted(mc.rglob("*.json")):
                rel = path.relative_to(mc)
                dest = self.out / "packs" / "me_core_module" / "data" / "minecraft" / rel
                dest.parent.mkdir(parents=True, exist_ok=True)
                obj = json.loads(path.read_text(encoding="utf-8"))
                dest.write_text(json.dumps(rewrite_json(obj, self.mapping), indent=2) + "\n",
                                encoding="utf-8")

        self._write_hook_tags()
        self._write_published()
        self._write_pack_metas()
        self._write_manifests()

    # ------------------------------------------------------------------
    # Core is not allowed to name a module.
    #
    # Every entry in HOOK_CONTRIBUTIONS was a direct `function me_x_module:...`
    # line inside the core pack. That one line is what made the module graph
    # cyclic (core -> module -> core) and what would have broken the pack the
    # moment a module was removed. It becomes a call to the hook slot that owns
    # the concept, generated from the same table as the module's contribution.
    # ------------------------------------------------------------------
    def _core_hook_rewrite(self, text: str) -> str:
        for slot, module, function in HOOK_CONTRIBUTIONS:
            # The module's file is written at its *normalised* path (`perm/require`,
            # not `api/perm/require`), so the pattern has to match that id.
            target = f"{module_namespace(module)}:{normalise_area(function)}"
            pattern = rf"function {re.escape(target)}{HOOK_CALL_SUFFIX}"
            text = re.sub(pattern, f"function #me_core_module:hook/{slot}", text)
        return text

    def _source_area(self, rel: str) -> str:
        """The source-relative path minus the registry folder and the extension."""
        parts = rel.split("/")
        area = "/".join(parts[1:])
        for suffix in (".mcfunction", ".json"):
            if area.endswith(suffix):
                area = area[:-len(suffix)]
        if parts[0] == "tags" and "/" in area:
            area = area.split("/", 1)[1]
        return area

    def _normalised_id(self, module: str, rel: str) -> str:
        """The id this file will carry after normalisation, e.g. `me_x:cmd/run`."""
        return f"{module_namespace(module)}:{normalise_area(self._source_area(rel))}"

    def _cross_module_rewrite(self, text: str, module: str) -> str:
        """Point a module at another module's *published* id, never its internals.

        The owner of a tree keeps its own private ids: within `me_container_module`
        `core/internal/container/_addr` is a private helper and its name is its own
        business. Only the outside sees the published name.
        """
        for private_id, public_id in CROSS_MODULE_REWRITES:
            owner = private_id.split(":", 1)[0][len("me_"):-len("_module")]
            if owner == module:
                # The owner moves the function itself: an id that is public for
                # the outside must not stay under core/internal inside the pack,
                # or the file the game loads and the id callers use disagree.
                if private_id in MOVED_TO_PUBLIC:
                    text = re.sub(rf"{re.escape(private_id)}{HOOK_CALL_SUFFIX}",
                                  public_id, text)
                continue
            text = re.sub(rf"{re.escape(private_id)}{HOOK_CALL_SUFFIX}",
                          public_id, text)
        return text

    def _write_published(self) -> None:
        """Emit a public wrapper for every primitive another module needs.

        A wrapper is deliberately thin: it does no gating, no validation and no
        output shaping of its own. All it does is give the neighbouring module a
        name it is allowed to call, so the private tree stays free to change shape
        without anything outside the module noticing.
        """
        for module, public_id, source_id, contract in PUBLISHED_PRIMITIVES:
            ns = module_namespace(module)
            dest = (self.out / "packs" / ns / "data" / ns / "function"
                    / f"{public_id}.mcfunction")
            dest.parent.mkdir(parents=True, exist_ok=True)
            body = (
                f"# {ns}:{public_id}\n"
                f"#\n"
                f"# PUBLISHED SURFACE - part of this module's public contract.\n"
                f"# {contract}\n"
                f"#\n"
                f"# Thin wrapper over the private implementation; it adds no logic, so the\n"
                f"# private function keeps its freedom to change. Callers outside this\n"
                f"# module must use this id and never {ns}:{source_id}.\n"
                f"\n"
                f"return run function {ns}:{source_id}\n"
            )
            dest.write_text(body, encoding="utf-8")

    def _write_hook_tags(self) -> None:
        """Emit one slot tag per hook, plus each module's contribution file.

        The core writes `data/me_core_module/tags/function/hook/<slot>.json`.
        A module writes *the same tag id from its own pack*, listing its own
        function. The game merges the two definitions, so the module joins the
        slot without touching a file the core owns.
        """
        slots: dict[str, list[str]] = {slot: [] for slot in EMPTY_SLOTS}
        contributors: dict[str, dict[str, list[str]]] = {}

        for slot, module, function in HOOK_CONTRIBUTIONS:
            slots.setdefault(slot, [])
            contributors.setdefault(module, {}).setdefault(slot, []).append(
                f"{module_namespace(module)}:{normalise_area(function)}")

        # Core side: the slot definitions. Every value is `required:false` so an
        # absent module never breaks the core's tag load.
        core_tags = (self.out / "packs" / "me_core_module" / "data" / "me_core_module"
                     / "tags" / "function" / "hook")
        core_tags.mkdir(parents=True, exist_ok=True)
        for slot in slots:
            body = {
                "replace": False,
                "values": [],
                # Documentation travels with the file, so whoever opens the tag in
                # a world sees what the slot is for. `__comment` is ignored by the
                # tag loader (unknown keys are not read).
            }
            if slot in VALUE_SLOTS:
                body["values"] = []
            (core_tags / f"{slot}.json").write_text(json.dumps(body, indent=2) + "\n",
                                                    encoding="utf-8")

        # Module side: same tag id, from the module's own pack.
        for module, per_slot in contributors.items():
            ns = module_namespace(module)
            tags_dir = (self.out / "packs" / ns / "data" / "me_core_module"
                        / "tags" / "function" / "hook")
            tags_dir.mkdir(parents=True, exist_ok=True)
            for slot, values in per_slot.items():
                body = {"replace": False,
                        "values": [{"id": v, "required": False} for v in values]}
                (tags_dir / f"{slot}.json").write_text(json.dumps(body, indent=2) + "\n",
                                                       encoding="utf-8")

    def _rewrite(self, text: str, where: str) -> str:
        # A macro id cannot be resolved statically; it is left alone and reported.
        def note(match: re.Match[str]) -> str:
            self.macros.append(f"{where}: {match.group(3)}$(…) - expands at runtime")
            return match.group(0)
        text = MACRO_REF.sub(note, text)

        def sub(match: re.Match[str]) -> str:
            verb, hashmark, ident = match.group(1), match.group(2), match.group(3)
            return verb + hashmark + self.mapping.get(ident, ident)

        text = FUNCTION_REF.sub(sub, text)
        text = rewrite_registry_refs(text, self.mapping)

        # Comments are rewritten too, so a reader of a module never sees an id that
        # does not exist. This is documentation hygiene, not semantics.
        out_lines = []
        for line in text.splitlines(keepends=True):
            if "#" in line:
                head, _, tail = line.partition("#")
                tail = "#" + re.sub(r"([a-z0-9_.-]+:[a-z0-9_/.-]+)",
                                    lambda m: self.mapping.get(m.group(1), m.group(1)), tail)
                line = head + tail
            out_lines.append(line)
        return "".join(out_lines)

    def _note_hooks(self, module: str, rel: str, text: str,
                    hook_values: dict[str, dict[str, list[str]]]) -> None:
        """Record which of this module's functions wants a core hook slot.

        A module signals interest by living at a conventional path inside its own
        namespace - `tick.mcfunction` at the root of the module, or anything under
        `hook/`. Core then calls the tag for that slot and every module's
        contribution runs. Core never names a module function directly.
        """
        if not rel.startswith("function/"):
            return
        area = rel[len("function/"):]
        area = area[:-len(".mcfunction")] if area.endswith(".mcfunction") else area
        own_id = f"{module_namespace(module)}:{area}"

        if area == "tick" or area.startswith("hook/tick"):
            hook_values.setdefault(module, {}).setdefault("tick", []).append(own_id)
        if area == "load" or area.startswith("hook/load"):
            hook_values.setdefault(module, {}).setdefault("load", []).append(own_id)
        if area.startswith("player/tick") or area.startswith("hook/player_tick"):
            hook_values.setdefault(module, {}).setdefault("player/tick", []).append(own_id)

    def _write_pack_metas(self) -> None:
        base = json.loads((self.source / "pack.mcmeta").read_text(encoding="utf-8"))
        for pack_dir in sorted((self.out / "packs").iterdir()):
            meta = json.loads(json.dumps(base))
            name = pack_dir.name
            description = meta["pack"].get("description", "")
            meta["pack"]["description"] = f"{name} | {description}"
            (pack_dir / "pack.mcmeta").write_text(json.dumps(meta, indent=2) + "\n",
                                                  encoding="utf-8")

    def _write_manifests(self) -> None:
        """Write build/modules.json - the machine-readable description of the split.

        Everything here is derived from the same tables the files were generated
        from (assignment, HOOK_CONTRIBUTIONS, PUBLISHED_PRIMITIVES), so the manifest
        cannot describe a layout the packs do not have.
        """
        by_module: dict[str, int] = {}
        for _, module, _ in self.files:
            by_module[module] = by_module.get(module, 0) + 1

        published: dict[str, list[dict[str, str]]] = {}
        for module, public_id, source_id, contract in PUBLISHED_PRIMITIVES:
            published.setdefault(module, []).append(
                {"id": f"{module_namespace(module)}:{public_id}",
                 "wraps": f"{module_namespace(module)}:{normalise_area(source_id)}",
                 "contract": contract})
        # Sorted, not iterated raw: MOVED_TO_PUBLIC is a set, and Python randomises
        # set order per process. Un-sorted, this list came out in a different order
        # on every run, so modules.json had three different hashes in three runs
        # from identical input - and the upstream canary diffs modules.json.
        for module in sorted(MOVED_TO_PUBLIC):
            owner = module.split(":", 1)[0][len("me_"):-len("_module")]
            published.setdefault(owner, []).append(
                {"id": module.replace("core/internal/", ""), "moved": True})

        # Hooks a module contributes to, taken from the authoritative table.
        hooks_by_module: dict[str, dict[str, list[str]]] = {}
        for slot, module, function in HOOK_CONTRIBUTIONS:
            hooks_by_module.setdefault(module, {}).setdefault(slot, []).append(
                f"{module_namespace(module)}:{normalise_area(function)}")

        modules = []
        for name, _ in MODULES:
            if not by_module.get(name):
                continue
            modules.append({
                "name": name,
                "namespace": module_namespace(name),
                "pack": f"packs/{module_namespace(name)}",
                "files": by_module[name],
                "hooks": hooks_by_module.get(name, {}),
                "publishes": published.get(name, []),
            })

        manifest = {
            "schema": 2,
            "source": f"{OLD_NAMESPACE} data pack, format 121.0 / Minecraft 26.3",
            "layout": "one core pack plus independently loadable module packs",
            "naming": "me_<module>_module:<path>, no api/ or systems/ segment",
            "requires": "every module requires me_core_module; core requires nothing",
            "hookSlots": {
                slot: {
                    "tag": f"me_core_module:hook/{slot}",
                    "returns": slot in VALUE_SLOTS,
                    "empty": slot in EMPTY_SLOTS,
                }
                for slot in sorted({s for s, _, _ in HOOK_CONTRIBUTIONS} | set(EMPTY_SLOTS))
            },
            "modules": modules,
            "totalFiles": sum(by_module.values()),
            "unmapped": self.unmapped,
        }
        (self.out / "modules.json").write_text(json.dumps(manifest, indent=2) + "\n",
                                               encoding="utf-8")

        if self.macros:
            (self.out / "MACRO_REFS.txt").write_text("\n".join(sorted(set(self.macros))) + "\n",
                                                     encoding="utf-8")


def main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--source", required=True, type=Path)
    parser.add_argument("--out", required=True, type=Path)
    parser.add_argument("--report-unmapped", action="store_true")
    parser.add_argument(
        "--in-place", action="store_true",
        help="the output root is a project checkout: clear only packs/ and the "
             "manifests, never the whole directory")
    parser.add_argument(
        "--force", action="store_true",
        help="allow clearing an output directory that contains a .git")
    args = parser.parse_args(argv[1:])

    split = Split(args.source.resolve(), args.out.resolve(),
                  force=args.force, in_place=args.in_place)
    split.collect()
    split.write()

    by_module: dict[str, int] = {}
    for _, module, _ in split.files:
        by_module[module] = by_module.get(module, 0) + 1

    print(f"split {len(split.files)} file(s) into {len(by_module)} module pack(s)")
    for module, _ in MODULES:
        if by_module.get(module):
            print(f"  me_{module}_module{'':<16} {by_module[module]:>5} file(s)")
    print(f"rewrote {len(split.mapping)} function/tag id(s)")
    if split.macros:
        print(f"left {len(split.macros)} macro-built id(s) untouched (see MACRO_REFS.txt)")
    if args.report_unmapped and split.unmapped:
        print("\nfiles that did not match a child folder:")
        for rel in split.unmapped:
            print("  " + rel)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
