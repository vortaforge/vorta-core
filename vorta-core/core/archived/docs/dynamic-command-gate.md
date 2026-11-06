# Dynamic command execution: inventory and gate

Several packs in this repository can execute a Minecraft command that is not
written literally in a `.mcfunction` file - a string from storage expanded by a
macro (`$$(cmd)`, `run $(cmd)`), a dynamically named `function` dispatch, or a
string copied into a command block. Those executors run at the server's
`function-permission-level`, not at the permission level of the player who
happened to trigger them, so who may feed them a string is a security
question. This document is the inventory of those surfaces and the switch
that now sits in front of each of them.

## Rule after this change

**Stored-string command execution is off by default in every pack that has
it.** An operator enables it per pack, deliberately, with the pack's own
config mechanism:

| Pack | Dynamic surfaces | Gate | How an operator enables it |
|---|---|---|---|
| `macroEngine-Datapack-v26.3` | stored-string executors (queue, hooks, wands, triggers, `multi_cmd`, `once_cmd`, region watchers, command-block runners) and the `api/cmd/*` string runners | `macroengine:systems/cmd_gate/check`: config switch + `cmd.dynamic` permission + length/control checks + root blocklist. Full contract: `packs/macroEngine-Datapack-v26.3/docs/cmd_gate.md` | `data modify storage macroengine:engine config_in set value {key:"dynamic_cmd",value:1b}` then `function macroengine:core/config/set`, and grant `cmd.dynamic` (directly or via a permission group) |
| `guikit-datapack` (retired source; historical distributions only) | historically, menu/button `cmd` actions (`play/act/cmd_do`, `internal/btn/cmd`) | `guikit:cfg dynamic_cmd` (storage, default `0b`, seeded in `core/load`) | `data modify storage guikit:cfg dynamic_cmd set value 1b` |
| `guikitfw` | menu `commands` actions (`act/_commands_one`) | same storage flag, seeded in `core/load` | `data modify storage guikit:cfg dynamic_cmd set value 1b` |
| `RTWrapper-v1.0.1` and `RTWrapper` | the single wrapper dispatch (`core/wrappers/handler/exec`) that every storage-driven request funnels through | score `#dynamic` in `rtw.config` (default 0, seeded in `core/load`) | `function rtwrapper:api/dynamic/on` (`.../off` to revert) |
| `TunnelScript` | the command-block runner (`tunnelscript_core:internal/run_block`) behind `ts:run*`, batches and the minecart input queue | score `#dynamic_enabled` in `tunnelscript.vars` (default 0), *in addition to* the existing `tunnelscript.trusted` tag and confirmation gate; dry-run preview still works while off | `function ts:config/dynamic_on` |
| `cmdTunnel-datapack` (archived, legacy format) | `cmd_tunnel_sys:run` → command block at 0 -66 0 | score `#dynamic` in `cmd_tunnel_cfg` (default 0, objective created by `init`) | `function cmd_tunnel_sys:dynamic_on` |
| `DailyBonus`, `QuickShare`, `LeftClickDetection`, `InteractionClickDetection`, `macroEngine-Resourcepack-v26.3` | none found | n/a | n/a |

"No surface found" means: no whole-command macro, no `run $(...)`, no dynamic
`function` dispatch and no storage-fed command block in the pack's
`.mcfunction` files. `python3 scripts/build_release.py` re-runs exactly this
scan on every release build and writes the line-by-line result to
`build/release/dynamic-surfaces.json`, so the inventory cannot silently rot -
diff that file when reviewing a change that touches command execution.

## Reviewed and deliberately not gated

Two patterns *look* dynamic in the scan but are not arbitrary-string
executors, so the default-off switch does not cover them:

* **Code-supplied `$(invoke)` helpers** in macroEngine (`systems/geo/*`,
  `player/inv/*`, `world/block_if|block_unless`): the invoked text is a macro
  argument written by another `.mcfunction` file in this repository, i.e. by
  already-trusted pack code. Gating them would not separate trusted from
  untrusted input; it would just break the pack's own features. If a future
  caller passes player-controlled text as `invoke`, that caller is the bug -
  `systems/cmd_gate/check` is the function to route it through first.
* **Prefix-constrained dispatch** in guikitfw (`guikit:cond/t_$(ctype)`,
  `guikit:act/$(kind)`, `guikit:widget/$(kind)`): the substituted text can
  only select among functions under one fixed prefix of the same pack; it
  cannot express an arbitrary command. Menu definitions stay operator-trusted
  input, as documented in the packs themselves.

`api/perm/run` and `api/perm/exec` in macroEngine keep their per-call
permission check *and* now also require the `dynamic_cmd` switch, so the
switch really is a master off for stored strings.

## Honest limits

* A datapack is plain text. Anyone who can edit the pack can delete the gate;
  anyone with operator rights can turn it on and grant themselves the
  permission. The gate separates *untrusted players* from function-level
  command execution and makes the trust decision explicit and auditable. It
  is a safeguard, not a sandbox (the same note `gate/version` already makes).
  Non-bypassable enforcement belongs in a Fabric mod.
* The blocklist in `systems/cmd_gate/blocklist` only inspects the first token
  of the command. `execute ... run op @s` has root `execute` and is not
  filtered by it. Do not treat the blocklist as the boundary; the boundary is
  *off by default* plus the `cmd.dynamic` permission.
* Macro executors capture their string through a quoted macro line
  (`set value "$(cmd)"`), as they already did before this change, so a command
  containing a double quote or backslash cannot pass through those specific
  executors at all. The command-block runners copy from storage and are not
  subject to that limit.
* macroEngine ships no Ward tests: `data/macroengine/test/` does not exist
  (the `cmd_gate_*` tests this paragraph used to cite were never added to the
  tree). The gate has been checked statically only (historically with Mecha,
  and now with Spyglass plus source inspection); no server execution is claimed.

## Why not obfuscation instead?

Hiding these executors behind name mangling, split-up macro strings, dead
code or encrypted sources would make this document impossible to write
honestly, would undermine static lint, the origin-watermark and repository
checks, and every existing world that references these namespaces -
and would look *more* like malware to any reviewer, human or automated, not
less. The defence against false-positive "this datapack is a virus" verdicts
is the opposite posture: plain readable source under the Unlicense, this
inventory, reproducible release ZIPs (`scripts/build_release.py`, with
SHA-256 sums), and dangerous strings off until an operator opts in.
