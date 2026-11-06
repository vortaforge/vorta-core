# Dynamic command gate (`systems/cmd_gate/*`)

Every macroEngine feature that executes a command **string from storage**
(the work queue, schedule/once helpers, hooks, wands, trigger bindings,
`multi_cmd`, region watchers and both command-block runners) passes through
`macroengine:systems/cmd_gate/check` first. The `api/cmd/*` string runners and
`api/perm/run|exec` read the same master switch. Nothing in this category runs
until an operator turns it on.

Cross-pack overview and the full surface inventory:
`docs/dynamic-command-gate.md` in the repository root.

## Enabling it

```mcfunction
# 1. Master switch (validated config path; survives /reload)
data modify storage macroengine:engine config_in set value {key:"dynamic_cmd",value:1b}
function macroengine:core/config/set

# 2a. Grant one player the permission directly
function macroengine:api/perm/grant {player:"Steve",perm:"cmd.dynamic"}

# 2b. ... or via a group (applies to present and future members on assign)
function macroengine:api/perm/group/create {group:"trusted"}
function macroengine:api/perm/group/grant_perm {group:"trusted",perm:"cmd.dynamic"}
function macroengine:api/perm/group/assign {player:"Steve",group:"trusted"}
function macroengine:api/perm/group/list
function macroengine:api/perm/group/remove {player:"Steve",group:"trusted"}
```

Groups are plain data in `macroengine:engine groups.<group>`: a list of
permission names, granted and revoked by admins only. Assign materialises the
list into the same `perm.<name>` tags `api/perm/require` has always checked,
plus a `group.<group>` membership tag, so no existing permission check in the
pack changes meaning. Adding a permission to a group affects a player the
next time the group is assigned to them.

Turning dynamic commands back off is the same config call with `value:0b`;
`macroengine:core/config/reset` also returns it to `0b`, like every other key.

## What the gate checks (in order, fail-closed)

1. `module_cmd` config is on.
2. `dynamic_cmd` config is `1b` (**default `0b`**).
3. The executor passes `api/perm/require` for `cmd.dynamic`
   (`macroengine.admin` or the `perm.cmd.dynamic` tag; a no-entity
   server/console/scheduled executor is trusted, the existing convention).
4. The string exists, is 1..`dynamic_cmd_max_len` characters (default 256),
   and contains no newline, carriage return or tab.
5. Its first token - the command root - is split off while the string is still
   data (string library, no macro substitution), checked free of quote and
   backslash, lower-cased, and compared against the blocklist.

A denial sets `macroengine:cmd_gate out {allowed:0b, error:"..."}` and returns
0; a blocklist hit also writes an audit entry (`cmd_gate.blocked`, detail =
the root). Callers use it exactly like `safe_name`:

```mcfunction
$data modify storage macroengine:cmd_gate in.cmd set value "$(cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$$(cmd)
```

## The blocklist

Defaults ship in `systems/cmd_gate/blocklist.mcfunction` and are meant to be
changed by editing that file in a pull request: `op`, `deop`, `stop`, `ban`,
`ban-ip`, `pardon`, `pardon-ip`, `kick`, `whitelist`, `save-off`, `reload`,
`datapack`, each also as `/name` and `minecraft:name`. They seed
`macroengine:engine cmd_blocklist` only when that key is missing, so an
operator may extend the list at runtime:

```mcfunction
data modify storage macroengine:engine cmd_blocklist append value "fill"
data remove storage macroengine:engine cmd_blocklist   # back to shipped defaults
```

The blocklist only sees the command root. It will not stop
`execute as @s run op @s`, because that command's root is `execute` - it is
defence in depth against accidents and against directly-stored dangerous
commands. The actual trust boundary is the default-off switch plus the
`cmd.dynamic` permission: grant it only to players you would also trust with
commands at `function-permission-level`.

## Limits worth knowing

- Macro-based executors capture their input with a quoted macro line
  (`set value "$(cmd)"`, as before this gate existed), so a stored command
  containing a double quote or backslash cannot traverse those paths at all
  and fails before the gate is reached. The command-block runners
  (`api/cmd/run_with_cb`, `api/cb`) copy from storage, and quoted commands
  keep working there - the gate normalises only the root token for them.
- Queued and scheduled commands execute later, usually with no entity as
  executor, which the permission step treats as trusted server context. Only
  datapack code (or an operator) can enqueue a command, and the master switch
  still applies at execution time.
- `systems/geo/*`, `player/inv/*` and `world/block_*` take an `$(invoke)`
  argument written by other pack code, not a stored string; they are
  intentionally outside this gate (see the root inventory).
- This is a safeguard inside a plain-text datapack, not a sandbox. It keeps
  player-triggered features from escalating into function-level commands by
  accident; it cannot stop someone who can edit the pack or who already has
  operator rights.
