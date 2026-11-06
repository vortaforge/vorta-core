# Core contract

`me_core_module` is the engine itself: internals, `load`, `tick`, and the hook slots
that modules attach to. This file defines what the core **promises** a module and
what it **expects** in return. Anything outside this contract is not guaranteed.

## 1. The core never calls a module by name

This is the single rule everything else rests on. When the core needs a module's
work, it does this:

```mcfunction
function #me_core_module:hook/trigger_dispatch
```

Note the `#`: this is not a function, it is a **tag**. The core does not know who
is inside it, and must not.

The module-side counterpart, in the module's **own pack**:

```json
// me_trigger_module/data/me_core_module/tags/function/hook/trigger_dispatch.json
{
  "replace": false,
  "values": [
    { "id": "me_trigger_module:core/internal/trigger/dispatch", "required": false }
  ]
}
```

Both files define **the same tag id**. Because `replace: false`, the game unions
them: the core's empty list plus the module's single entry. The result is that the
core's `#me_core_module:hook/trigger_dispatch` call runs the module's function.

`required: false` is not incidental either: if the module is absent, the core's tag
still loads. Deleting a module does not break the pack — that feature simply stops.

## 2. Slot list

| Slot | Runs at | Returns | Contributor |
|---|---|---|---|
| `tick` | every tick | — | (empty; for third parties) |
| `load` | world load | — | (empty) |
| `player_tick` | every tick, player context | — | (empty) |
| `cb_tick` | while the command block queue is non-empty | — | `me_cb_module` |
| `cmd_freeze_tick` | every tick | — | `me_cmd_module` |
| `interaction_tick` | every tick | — | `me_interaction_module` |
| `wand_tick` | every tick | — | `me_wand_module` |
| `trigger_dispatch` | every tick, player action score > 0 | — | `me_trigger_module` |
| `perm_tick` | every tick | — | `me_perm_module` |
| `perm_require` | when a permission is asked for | **yes** | `me_perm_module` |
| `player_get_name` | name resolution | **yes** | `me_player_module` |
| `player_enumerate` | load, step 2 | — | `me_player_module` |
| `player_resolve` | load, step 3 | — | `me_player_module` |
| `player_init` | load, step 4 | — | `me_player_module` |
| `player_init_online` | load, for online players | — | `me_player_module` |
| `player_init_from_name` | a player resolved from a name | — | `me_player_module` |

### Value-carrying slots

A tag can run several functions, so there is no single "return value of a tag".
What the game does:

- `execute store result ... run function #tag` → the **sum** of the contributors' return values
- `unless function #tag` → succeeds when the whole tag returns non-zero

While there is a single contributor, this is exactly the old scalar return.
`perm_require` and `player_get_name` have one contributor today; if a second is
added the values sum — do that deliberately, not by accident.

## 3. Services the core publishes

Modules may call these ids; the whole list is a stable surface and its signatures
do not change:

| Id | Purpose |
|---|---|
| `me_core_module:text/split` | split text on a separator → `macroengine:output` |
| `me_core_module:text/concat` | join text values |
| `me_core_module:text/safe` | is the string safe as a score/tag literal (1/0) |
| `me_core_module:text/ctl` | does it contain a control character |
| `me_core_module:text/lower` / `upper` | change case |
| `me_core_module:text/replace` | replace text |
| `me_core_module:text/reset` | clear the text scratch space |
| `me_core_module:core/ext/perm_count` | permission counter |
| `me_core_module:core/ext/player/add_var_clamped` | clamped add to a player variable |
| `me_core_module:core/ext/player/toggle_var` | flip a player variable |
| `me_core_module:core/ext/world/count_near` | count nearby entities |

### `core/internal/` is where every implementation lives

This is the load-bearing rule of the whole split, and it is the one that took two
attempts to get right:

> **Every function that implements something lives in `me_core_module`, under
> `core/internal/`. A module ships its public surface and nothing else.**

A module *does* call `me_core_module:core/internal/...` — that is the normal,
intended case, not a violation. There is one implementation of a feature, it is in
core, and every caller reaches it by fully-qualified id.

What must never happen is a module shipping its own copy:

```
data/me_cb_module/function/core/internal/cb/apply_defaults.mcfunction   ← wrong
```

That path reads like core's tree, resolves like a real id, and passes a reference
check — but it is private to `me_cb_module`, it is a second copy of core code, and
deleting the module silently deletes it. `verify.py` reports it as
`module-internal` and fails the build. `test_split_guard.py` also refuses a
`MODULES` table in which anything but core claims a `core/internal/` prefix, so the
generator cannot produce the shape in the first place.

Three functions are shared by core and a module (the store renderer, the multi_cmd
executor, the player initialiser). Those are infrastructure, so they live in core;
the feature keeps a thin public function at its own id that forwards to them.

## 4. What a module is expected to do

1. Namespace `me_<name>_module`, ids `me_<name>_module:<path>`; no `api/` or
   `systems/` segment (the naming rule `split.py` applies).
2. No implementation of your own. Your pack contains your public functions; the
   code behind them is `me_core_module:core/internal/<area>/...` and you call it by
   id. Reaching into *another module's* namespace is still forbidden - modules
   never call each other's public surface either, they both call core.
3. `min_format`/`max_format` in `pack.mcmeta` (the form 26.x reads).
4. To join a hook, write
   `data/me_core_module/tags/function/hook/<slot>.json` in your own pack — do not
   **edit** the core's file.

## 5. What gets checked

`python3 tools/verify.py --pack packs` (or `gradlew check`) looks for:

- unresolvable function/tag references (`dangling`)
- a real call still pointing at the old `macroengine:` namespace (`old-namespace`)
- a module shipping a `core/internal/` tree of its own (`module-internal`)
- a module calling another module (`private-access`)
- the core calling a module by name (`hooks`)
- a cycle in the module dependency graph (`cycle`)
- a missing `pack.mcmeta` or an empty pack (`pack-layout`)

Zero problems = `[verify] OK`.
