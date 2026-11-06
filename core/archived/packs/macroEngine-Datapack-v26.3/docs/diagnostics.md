# Diagnostics

A read-only health check for the engine. It reads what the engine already stores (config, module flags, queue, log, audit) and reports problems as short codes. It does not repair anything.

```
function macroengine:api/diagnostics/report     # prints a report to the caller (macroengine.admin tag required)
function macroengine:api/diagnostics/status     # no output; returns the number of issues (0 = healthy)
function macroengine:systems/diagnostics/collect  # the collector both of them call
```

A player caller needs the `macroengine.admin` tag for `status` and `report`. A non-player caller (console, another datapack) may call `status` and `collect`. Every function starts with the usual gate and consent guard, so nothing runs while the pack is closed; use `gate/status` or `gate/report` to see why.

## Output

`macroengine:output diagnostics`:

| Key | Meaning |
| --- | --- |
| `ok` | `1b` when `issues` is empty |
| `issue_count`, `notice_count` | length of `issues` and `notices` |
| `issues` | problem codes (below) |
| `notices` | informational codes (below), not problems |
| `modules` | `{enabled, disabled}` counts |
| `queue` | `{size, cap}` |
| `audit` | `{count}` |
| `log` | `{level, buffered}` |

## Issue codes

| Code | Meaning |
| --- | --- |
| `config.missing`, `config.rev_missing`, `config.schema_missing` | the config, its revision marker or its schema is absent from `macroengine:engine` |
| `config.not_applied:<key>` | `core/config/apply` has not copied that key to the score the engine reads |
| `module.missing:<name>` | `modules.<name>` does not exist |
| `module.invalid:<name>` | `modules.<name>` is not `0b` or `1b` |
| `module.mismatch:<name>` | `modules.<name>` differs from `config.module_<name>` |
| `queue.over_cap` | the work queue is longer than `queue_max_depth` |
| `queue.not_draining:sys_queue_off` | the queue has entries but `sys_queue` is off |
| `engine.not_loaded` | `global.loaded` is not `1b` |

## Notices

`security.dynamic_cmd_enabled`, `tick.paused_storage`, `tick.paused_config`, `log.debug_level`, `audit.buffer_full` (100 entries, oldest are being dropped).

## What it does not do

- It does not measure CPU or tick time. It reports stored state, not performance.
- It does not count rate-limit denials or errors; the engine does not keep those counters.
- It does not fix anything. Use `core/config/set`, `core/config/apply` or a reload.
- The module list in `systems/diagnostics/checks/modules` must be kept in sync with `core/config/apply`.

It writes only its own output storage, scratch scores (`#macroengine.dg_*` in `macroengine.tmp`) and a scratch storage (`macroengine:diagnostics work`) that it removes before returning. This is based on a static read of the source; it has not been run in-game.
