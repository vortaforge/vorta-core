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

Nothing under `core/internal/...` is part of the contract. If a module looks there,
`verify.py` fails the build — deliberately: the freedom to change that tree exists
only while nobody leans on it.

## 4. What a module is expected to do

1. Namespace `me_<name>_module`, ids `me_<name>_module:<path>`; no `api/` or
   `systems/` segment (the naming rule `split.py` applies).
2. No reaching into another module's `core/internal` tree. If you need it, that
   module **publishes** the function and you call the published id.
3. `min_format`/`max_format` in `pack.mcmeta` (the form 26.x reads).
4. To join a hook, write
   `data/me_core_module/tags/function/hook/<slot>.json` in your own pack — do not
   **edit** the core's file.

## 5. What gets checked

`python3 tools/verify.py --pack packs` (or `gradlew check`) looks for:

- unresolvable function/tag references (`dangling`)
- a real call still pointing at the old `macroengine:` namespace (`old-namespace`)
- a module accessing another module's internal tree (`private-access`)
- the core calling a module by name (`hooks`)
- a cycle in the module dependency graph (`cycle`)
- a missing `pack.mcmeta` or an empty pack (`pack-layout`)

Zero problems = `[verify] OK`.
