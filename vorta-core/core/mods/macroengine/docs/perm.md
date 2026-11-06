# Permissions: switches and per-command permissions

macroEngine's permission system is the `perm.<name>` tag system behind `api/perm/*`. A function that needs
a permission starts with `api/perm/require` (a player passes with the tag `macroengine.admin` or `perm.<name>`;
a server/console executor with no entity is trusted). This page covers the switches around it.

## Switches

| Switch | Function (run by a console/command-block executor or a player with the `macroengine.admin` tag) | Effect |
|---|---|---|
| enforcement | `api/toggle/perm/enforce_on` / `enforce_off` | off: `api/perm/require` and `api/perm/check` pass for everybody, nobody needs `/op` or a tag |
| default | `api/toggle/perm/default_on` / `default_off` | the value enforcement gets when `perm_enforce` is created or `core/config/reset` runs; does not change the current state |
| per-command | `api/toggle/perm/cmd_on` / `cmd_off` | on: each `api/cmd/<name>` wrapper needs the permission `cmd.<name>` (e.g. `cmd.gamemode`) |
| module | `api/toggle/perm/true` / `false` | `module_perm`; off now means "permission checks pass", it used to make every `api/perm/require` caller fail |
| status | `api/toggle/perm/status` | prints `perm_enforce`, `perm_cmd`, `perm_default`, `module_perm` |

The same keys work through `core/config/set` (`perm_enforce`, `perm_cmd`).

```mcfunction
# turn the permission system off for this world, and keep it off after a config reset
function macroengine:api/toggle/perm/enforce_off
function macroengine:api/toggle/perm/default_off

# per-command permissions: only players with perm.cmd.gamemode (or the admin tag) may use api/cmd/gamemode
function macroengine:api/toggle/perm/enforce_on
function macroengine:api/toggle/perm/cmd_on
function macroengine:api/perm/grant {player:"Steve",perm:"cmd.gamemode"}
```

Shipped defaults: `perm_enforce` follows `perm_default` (ships as `1b`, so nothing gets looser when you update),
`perm_cmd` is `0b` (the `api/cmd/*` wrappers stay unchecked unless you switch it on).

## What the switches do not change

- `systems/cmd_gate` (stored command strings) is strict: it asks `api/perm/require` with `in.strict:1b`, so turning
  enforcement or the perm module off never opens `cmd.dynamic`. `dynamic_cmd` stays its own switch.
- `api/perm/grant`, `revoke` and the group functions still need the `macroengine.admin` tag (or a no-entity executor).
- The `macroengine.admin` tag itself is still set by an operator (`/tag <player> add macroengine.admin`) or from the
  console. A datapack cannot tell a real operator from a player in a function context, so there is no function that
  hands out the admin tag on request. If you do not want to manage tags, switch enforcement off.
- `api/cmd/run_with_cb` and `api/cmd/data_remove_storage` keep their own checks and are not covered by `perm_cmd`.
