# Using macroEngine next to other packs

This page describes source inspection and historical static linting (originally
with Mecha; the current static checker is Spyglass). The old guikit datapack
is now retired. Nothing here was run in a Minecraft server.

## 1. Is macroEngine usable right now?

```mcfunction
execute if function macroengine:gate/is_open run function mypack:use_macroengine
```

`gate/is_open` reads one score (`#macroengine.open` in `vortaforge.gate`), prints nothing and returns 1 or 0. It has
no gate guard on purpose, so it can answer while the pack is closed (not approved, consent pending, incomplete or
reload-looping load).

`vortaforge.gate` is a shared objective: `RTWrapper-v1.0.1` creates it too,
as did historical `guikit-datapack` distributions, each with its own fake
players (`#macroengine.*`, ...). Read your own fake players; do not write to
another pack's.

## 2. Extension points (function tags)

Function tags merge across datapacks, so another pack can append entries to these. Remember that anything you add
runs at the permission level of the server (`function-permission-level`).

| Tag | Fired | Executor |
|---|---|---|
| `#macroengine:init` | once, at the end of the load chain (`core/internal/load/final`) | whoever ran the load chain (normally nobody) |
| `#macroengine:loop` | every tick | each online player (`execute as @a`, `core/tick`) |
| `#macroengine:admin/run` | every tick for players whose `macroengine_run` score is 1 or more | that player |
| `#macroengine:input/writable_book`, `/lectern`, `/sign`, `/name_tag`, `/anvil` | after text was captured into `macroengine:input` | see the capture function under `input/private/` |
| `#macroengine:input/command_block_minecart` | after a command block minecart capture | the minecart's owner, else the nearest player within 8 blocks |
| `#macroengine:events/on_death`, `on_respawn`, `on_join`, `on_enchant`, `on_jump` | from the matching bridge under `core/internal/systems/hook/` | the player |
| `#macroengine:events/on_lc`, `on_rc`, `on_open_gui`, `on_load` | tag files exist; look up the dispatch site with `grep -rn "events/on_lc" data` before relying on the executor | - |

There is no `#macroengine:events/on_tick`; use `#macroengine:loop`.

## 3. Storage

- Arguments go in `macroengine:input`, results come back in `macroengine:output` (the function header says which).
  `macroengine:input` is scratch space that macroEngine overwrites, so never keep your own data there.
- `uuid/*` results are in `macroengine:output uuid` / `uuid_array` since the 2026-10-28 change.
- Do not substitute text a player typed into a macro line. Validate with `input/validate/check` and pass it as a macro
  argument (see `docs/store.md`).

## 4. Entities and tags macroEngine touches

macroEngine selects entities by its own tags (`macroengine.*`) and, in `core/internal/player`, by `player_action.*`.
A search for `kill`, `tp` and `data ... entity` on untagged `@e[type=...]` selectors found exactly one, in
`core/tick/player_systems`, and it only matches dropped items that carry macroEngine's own `custom_data`.
`api/interaction/remove` now also requires `macroengine.interaction`, so a tag you share with another pack's
interaction entities can no longer be removed through it.

`player/inv/chest_minecart_*` and `player/inv/transfer_item` match a `chest_minecart` within 2 blocks that carries a
tag you pass in. That is the hook for chest-minecart menus from other packs.

## 5. Known conflicts between packs

| Conflict | What happens | Status |
|---|---|---|
| `core/internal/player` uses un-namespaced `player_action.*` objectives, tags and interaction entities | Another pack that bundles the same names (for example the upstream PlayerAction library this code derives from) shares them: both packs read and clean up each other's state | **Open.** Phase 1 of `playeraction-rewrite-plan.md` renames them. It changes runtime identifiers stored in existing worlds, so it needs a migration plan and in-game testing first |
| Historical `guikit-datapack` distributions and `guikitfw` both use the namespace `guikit` | Enable only one; the merge manifest includes `guikitfw` | The old source is retired; `guikitfw` is the successor |

## 6. Merging with other packs

`packs/merge-manifest.json` drives `./gradlew mergeDatapacks`. Its `output.min_format` / `max_format` must match the
format of the included packs (`[121,0]` for 26.3), and every included pack needs a top-level `pack.mcmeta`.
