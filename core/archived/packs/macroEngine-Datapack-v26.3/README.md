# macroEngine (v26.3)

**macroEngine** is a macro/module framework datapack for Minecraft Java Edition, providing a large library of reusable command-based systems (math, string, NBT, geo, permissions, UUID cache, hooks, rate limiting, and more) plus a multi-source text/value input system (books, signs, lecterns, name tags, command block minecarts).

> **Project history:** originally developed under the `runtoolkit` organization (`runtoolkit/suite`), later moved to `vortacraftmc`. Both organizations are now archived — kept online and publicly visible, never deleted, but no longer maintained. Active development moved to **VortaForge** (`vortaforge/core`), where this pack is actively maintained; nothing in this history was deleted or hidden.
>
> Minecraft: **26.3** (`min_format` / `max_format` **121.0**)
>
> License: Unlicense (third-party components listed in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md))
>
> Namespace: `macroengine`
>
> AI disclosure: portions of this pack's code, documentation and refactoring were produced with AI assistance. This is stated explicitly rather than left to the commit author field — see [`CREDITS.md`](../../CREDITS.md) if present, or the repository's AI-disclosure notes. This is not a statement that every line was AI-written, only that AI assistance was used in this project's development and is not being concealed.

---

## Features

![macroEngine layers](docs/media/architecture.svg)

- **API layer** (`api/`) — stable public entry points: `cmd`, `cb` (callback queue), `color`, `gamerule`, `interaction`, `item`, `macro`, `perm`, `store`, `title`, `toggle`, `trigger`, `wand`, plus `block` (custom block entity interface) and `container` (slot and inventory helpers)
- **Systems layer** (`systems/`) — internal utility modules: `math`, `string`, `nbt`, `logic`, `geo`, `flag`, `hook`, `log`, `rate_limit`, `sound`, `uuid`, `color`
- **Input system** (`input/`) — capture player-provided values via writable book, sign, lectern, name tag, or command block minecart, with shared validation (`input/validate`) for int/float/bool/tag-safe strings
- **Toggle system** — per-module runtime enable/disable for `cb`, `perm`, `geo`, `wand`, `interaction`, `hook`, `block`, and `container` modules (`block` and `container` are the two load gates of the new API: `function macroengine:api/toggle/<module>/false` closes one)
- **Rate limiting** — global, per-player, and per-channel request throttling
- **Hook system** — bind functions to fire on events such as block break, dimension change, and advancement grant
- **Item modifiers** (`item_modifier/`) — reusable `item_modifier` definitions for enchanting, glint, lore, tooltip, and rename operations
- **Advancement-driven triggers** (`advancement/`) — core, hidden, and system advancements used to drive internal logic and hooks
- **Command conditions and nested groups** (`api/cmd/other/multi_cmd/`) — queue entries accept a `condition` object with boolean composition (`all_of`, `any_of`, `not`, nestable to depth 8) and a `commands` list that expands in place, so a group can be gated as a unit. Leaves: `tag`, `score` (target and bounds now optional), `predicate`, `entity`, `storage` (existence), and `data` (numeric range). Every leaf fails closed — a missing required key or an unreadable path reports *not passed* rather than silently passing
- **Deterministic RNG** (`systems/rng/`) — `seed`, `state`, `next`, `int`, `chance`, `pick`. Seeding makes randomised behaviour reproducible, which the previous generator could not do: it kept an undocumented `_rng_state` key with no way to set it. `systems/math/random` is now a thin wrapper over `systems/rng/int`, so there is one generator rather than two
- **Text-component rendering** (`systems/text/`) — helpers for NBT-backed components. On 26.1+ a `{"storage":...,"nbt":...}` component renders a string *with its quotes* and a number or boolean *with vanilla colouring* unless `interpret` and `plain` are both set. Every such component in this pack now sets both explicitly; `scripts/fix_text_components.py` at the repository root enforces it

- **Store module** (`api/store/`) — storage-based variables, per-player values, raw NBT helpers (`api/store/nbt/*`: `get`, `set`, `set_default`, `append`, `merge`, `remove`, `exists`, `count`, `copy`, `add`, `toggle`, `pop`, `shift` over any storage/path) and multilingual message templates (`render`, `render_all`, `convert`, `show`) that return plain strings; see [`docs/store.md`](docs/store.md). It replaced the old `api/data` and `api/placeholder` modules. Untrusted text is never substituted into a command or JSON string, so chat/sign/book input is safe. Migration notes: [`docs/migrating-from-data-api.md`](docs/migrating-from-data-api.md)
- **Title / action bar with tokens** (`api/title/*_p`, plus `clear`, `reset`, `times`; see [`docs/title.md`](docs/title.md)) — storage-driven (no quote/backslash breakage), rendered with `api/store/render` per recipient
- **Text UI** (`tui/`) — `line`, `header`, `divider` and `button` print formatted lines and clickable function buttons to the executor from storage (no text is pasted into a command); see [`docs/tui.md`](docs/tui.md)
- **Cross-pack use** — [`docs/interop.md`](docs/interop.md): how to detect macroEngine from another pack, which function tags other packs can extend, which storage to use, and the known conflicts between packs in this repository
- **Runtime config** (`core/config/*`, see [`docs/config.md`](docs/config.md)) — every behaviour knob is a validated key: module on/off switches, tick systems and rates, handler scan intervals, queue depth, template limits and token switches, title defaults, name length

---

## Requirements

- Minecraft Java Edition **26.3**
- Datapack `min_format`/`max_format`: **121**

---

## Installation

macroEngine is a datapack: it ships as a folder (or zip) that goes into a world's `datapacks/` directory. There is no separate "installer" — the steps below just cover different ways of getting the folder there and reloading it, for different setups.

### Singleplayer / any OS (manual, UI-based)

1. Download or clone this pack so you have the `macroEngine-Datapack-v26.3` folder (or a zip of it).
2. Open your world's folder and go into `datapacks/`. In the Minecraft world-select screen this is reachable via **Edit → Open World Folder**.
3. Copy the `macroEngine-Datapack-v26.3` folder in (or the zip — Minecraft can load zipped datapacks directly, no need to extract).
4. Load the world (or if already in it, run `/reload`), then run `/datapack list enabled` to confirm `macroengine` is listed.

### Linux / macOS (Bash)

```bash
# Run from the repository root
WORLD_DIR="$HOME/.minecraft/saves/YourWorldName"   # adjust to your world path
cp -r packs/macroEngine-Datapack-v26.3 "$WORLD_DIR/datapacks/"
```

For a dedicated server (any Linux distribution — Debian/Ubuntu, Fedora/RHEL, Arch, etc. — the steps are identical, since this only touches the world save, not the OS):

```bash
SERVER_WORLD_DIR="/path/to/server/world"
cp -r packs/macroEngine-Datapack-v26.3 "$SERVER_WORLD_DIR/datapacks/"
# Then, from the server console or an operator in-game:
#   /reload
```

### Windows (PowerShell)

```powershell
# Run from the repository root
$WorldDir = "$env:APPDATA\.minecraft\saves\YourWorldName"   # adjust to your world path
Copy-Item -Recurse -Path "packs\macroEngine-Datapack-v26.3" -Destination "$WorldDir\datapacks\"
```

For a Windows-hosted dedicated server, replace `$WorldDir` with the server's world directory and run `/reload` from the console or in-game as an operator afterward.

### Server install, in general

1. Copy the pack folder into the **world's** `datapacks/` directory on the server (not the server's root directory — datapacks are per-world).
2. Run `/reload` as an operator, or restart the server.
3. Run `/datapack list enabled` to confirm `macroengine` loaded without errors; check the server log for any function errors on load.
4. macroEngine initializes automatically via `#macroengine:events/on_load` — no further setup commands are required for the base install.

### Installing via Claude Code (or another coding agent)

If you're scripting the install (e.g. provisioning a test server, or doing it as part of a larger Claude Code task), the operation is just a directory copy plus a `/reload`; there is no build step for the datapack itself. For example, ask Claude Code to:

> "Copy `packs/macroEngine-Datapack-v26.3` from this repo into `<world-path>/datapacks/`, then tell me the server needs a `/reload` or restart to pick it up."

Claude Code (or any agent) can safely automate the file copy; it cannot run `/reload` for you unless it has console/RCON access to the running server — that step still needs an operator.

To check the default tick configuration, see `data/macroengine/function/config/`.

---

## Usage

Most functionality is exposed through the `api/` namespace, e.g.:

```mcfunction
function macroengine:api/cmd/actionbar
function macroengine:api/perm/grant
function macroengine:api/wand/give
```

Internal systems under `systems/` are used by API functions and are not intended to be called directly by end users, though they remain accessible for advanced/custom integrations.

---

## Notes

- This is the 26.3 build of macroEngine, derived from the earlier build in the archived `runtoolkit/suite` monorepo (`packs/macroEngine-Datapack-v26.3`). Development continues in `vortaforge/core`; do not file issues or PRs against `runtoolkit/*`.

---

## FAQ

> This section is based on a **static review** of the source (the code was read, not run in-game). Test on a staging server before deploying to production.

### Is it safe?

**Short answer:** no malicious content was found, but it is not safe to install blindly either. It is a powerful toolkit and can be dangerous if misused.

- **What is not in the pack:** the zip contains no `.jar`, `.exe`, scripts, `.git/` or `.env` files, only datapack files (`.mcfunction`, `.json`, `pack.png`). A datapack cannot open network connections or write to the server's file system on its own.
- **The real risk is the command-executing APIs.** Several functions run a caller-supplied string as a command (the `$execute ... run $(cmd)` pattern: `api/cmd/as_player`, `api/cmd/other/run_*`, `api/perm/run`, `api/perm/exec`, `core/lib/queue_add_cmd`, `core/lib/schedule_cmd`). Passing player-controlled text (sign, book, name tag) into them results in **command injection**.
- **The input system does not execute input.** Captured raw text is only written to the `macroengine:input` storage. Validate it with `input/validate/check` (`int`, `float`, `bool`, `tag_safe`) before using it.
- **There is built-in protection, but it is a safeguard, not a sandbox.** Every non-empty `api/` function starts with the load gate (`#macroengine.open`) and the per-player consent gate; module functions also check their module switch (`api/toggle/*` and `api/diagnostics/*` do not, so they keep working when a module is off). Functions that run a command *string* (`api/cmd/as_player`, `api/cmd/other/run_*`, `api/perm/run`, `api/perm/exec`) do nothing unless an operator sets `dynamic_cmd` to `1b` (default `0b`). The stored-command features (queue, schedule, hooks, wands, trigger bindings, `multi_cmd`, `api/cmd/run_with_cb`) also require the `cmd.dynamic` permission and a command-root blocklist, see [`docs/cmd_gate.md`](docs/cmd_gate.md). `api/perm/require` is enforced by default (`perm_enforce` `1b`); the per-wrapper permission `cmd.<name>` is off by default (`perm_cmd` `0b`), see [`docs/perm.md`](docs/perm.md).
- **What the protection does not cover.** There is no isolation between datapacks: any other datapack in the same world can call these functions. The blocklist only inspects the command root, so it does not stop `execute ... run op @s`. The `$(invoke)` helpers in `systems/geo/*`, `player/inv/*` and `world/block_*` are outside the dynamic-command gate by design. A datapack is plain text, so anyone who can edit the pack can remove these checks.
- **Permission level:** everything runs at the server's function permission level.

### Can I install it on a server?

Yes. It is a purely server-side datapack, and players do not need any mods. Requirements:

1. **Version:** the pack targets `26.3` (pack format `121.0`).
2. **Text rendering:** use it together with `macroEngine-Resourcepack-v26.3`.
3. **Back up first** and try it on a test server.
4. **Removal:** delete the pack from the world's `datapacks` folder (Realms: re-upload the world without it). The pack no longer ships server-administration commands (`/datapack`, `/op`, ...).

### Is it paid?

No. macroEngine's original code is released under the **Unlicense** and may be used commercially. The pack also contains PlayerAction, which is licensed under MIT: keep its copyright and permission notice in copies or substantial portions. See [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md). This is not legal advice.

### How is the performance?

Not measured. From the code: while players are online, the `time`, `player` and `queue` systems run **every tick**, `hud` every 2 ticks and `admin` every 4 ticks. `player_systems` also runs NBT-filtered `execute as @e` / `kill @e` scans over all `item` entities every tick, so cost grows with the number of dropped items. Systems you do not use can be turned off with `systems/flag/toggle_system`.

### Screenshots and demos

<!--
In-game media is not included yet. Add real captures under docs/media/ and uncomment:

![Input capture via writable book](docs/media/input-book.gif)
-->

The diagrams above are generated from the source code. Real in-game captures (input capture) are not available yet.

## Known Issues

- **Single target.** Minecraft Java 26.3 (data pack format `121.0`). Other versions are not tested and may not load.
- **Forceload side effects.** On load the pack runs `forceload add 0 0` and `forceload add -30000000 1600`. Cleanup only runs `forceload remove 0 0`, which also removes a `0 0` forceload the server owner added themselves, and `-30000000 1600` is **never removed** (if it lies outside the world border, the command may fail silently).
- **Command-string APIs are gated by a master switch, not by caller identity.** With `dynamic_cmd` on, `api/cmd/as_player`, `api/cmd/other/run_*` and `api/perm/run|exec` apply no command-root blocklist and no `cmd.dynamic` check, and the per-wrapper permission is off by default (`perm_cmd`). See "Is it safe?".
- **NBT-filtered `@e[type=item]` scan every tick** (performance note above).
- **Older archive contents may differ.** Verify that a particular archive contains `LICENSE` and `THIRD_PARTY_LICENSES.md` before redistributing it. The current source uses `_vc_origin.mcfunction`; the Gradle individual-pack ZIP strips it from a temporary copy, while `scripts/build_release.py` retains it.

## License

- macroEngine original code: Unlicense — see [`LICENSE`](LICENSE).
- PlayerAction: MIT, with copyright and license text in [`THIRD_PARTY_LICENSES.md`](THIRD_PARTY_LICENSES.md); retain that notice when redistributing the applicable code.
- String module (`core/lib/string`, `core/internal/text`): macroEngine original code.

Current individual-pack build paths include both license files; merged packs carry notices from their included source packs.
