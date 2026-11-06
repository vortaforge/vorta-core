# VF Macro Backport

> **Version support (v1.5.6)**  
> Ready-Command + parts API (pure system, no ostr) (`$(name)` etc.) works reliably on **1.20 / 1.20.1**.  
> On 1.16–1.19 the pack loads and the engine / return / if_function APIs work; use `api/macro/run` with a finished command string for macros.  
> Ostr technical blocks use y=0 for 1.16+ height compatibility. See `COMPAT.md` for the full matrix.


**VortaForge-compatible macro system for Minecraft 1.16–1.20**

Brings core macro features (`$(var)` substitution), `/return` simulation, and a built-in command execution engine to versions lacking native support—completely independent of external plugins or third-party engines.

## Installation

1. Drop the `vf-macro-backport` folder into your world's `datapacks/` directory.
2. Run `/reload` in the game.

---

## Quick Start

### 1. Macros (`$(key)` Substitution)

Define your arguments, set your template, and run:

```mcfunction
# 1. Set variables
data modify storage vf_macro:args name set value "Steve"
data modify storage vf_macro:args amount set value "5"

# 2. Set template
data modify storage vf_macro:in template set value "say Hello $(name), you received $(amount) diamonds!"

# 3. Run (template API — expands $(...) then executes)
function vf_macro:api/macro/template
```

For structured fragments (parts API) — **only compounds** (NBT lists cannot mix strings & compounds):

```mcfunction
data modify storage vf_macro:in parts set value [
  {text:"say Hello "},
  {key:"name"},
  {text:", you received "},
  {key:"amount"},
  {text:" diamonds!"}
]
data modify storage vf_macro:args name set value "Steve"
data modify storage vf_macro:args amount set value "5"
function vf_macro:api/macro/parts
```

### 2. `/return` Simulation

Early-exit flag checks for functions:

```mcfunction
# Success return
function vf_macro:api/return/success

# Fail return
function vf_macro:api/return/fail

# Return with value (e.g., 5)
# Prefer setting storage first:
data modify storage vf_macro:in value set value 5
function vf_macro:api/return/value
# or rely on score #vf_macro.return_value

# Check on the caller side:
execute if score #vf_macro.returned vf_macro matches 1 run ...
```

### 3. Direct Command Execution

```mcfunction
data modify storage vf_macro:in Command set value "say Hello!"
function vf_macro:api/macro/run
```

### 4. `if function` Simulation (`api/if_function/run`)

Simulates the success/fail behaviour of modern `execute if function ...`.

The result is determined by:
1. Command-block `SuccessCount` (0 = invalid command / missing function → fail)
2. Explicit return API (`return/fail` → fail, `return/success` or `return/value` → success)

**Important — Timing:**  
The engine is asynchronous. `#vf_macro.if_success` becomes valid **~2 ticks later**.

```mcfunction
data modify storage vf_macro:in Command set value "function mypack:my_test"
function vf_macro:api/if_function/run

# Wait ≥ 2 ticks, then:
execute if score #vf_macro.if_success vf_macro matches 1 run say The function succeeded
execute if score #vf_macro.if_success vf_macro matches 0 run say Failed (return fail / invalid / missing)
```

Typical pattern with a scheduled continuation:

```mcfunction
# in your caller
data modify storage vf_macro:in Command set value "function mypack:check_something"
function vf_macro:api/if_function/run
schedule function mypack:after_if_check 2t
```

```mcfunction
# mypack:after_if_check
execute if score #vf_macro.if_success vf_macro matches 1 run function mypack:on_success
execute if score #vf_macro.if_success vf_macro matches 0 run function mypack:on_fail
```

---

## Storage & Namespaces

| Path | Purpose |
| --- | --- |
| `vf_macro:in` | Input data (template, command, parts list, value) |
| `vf_macro:args` | Macro arguments (`name`, `amount`, etc.) |
| `vf_macro:out` | Output and results (incl. `return_success`, `return_value`) |
| Scoreboard `vf_macro` | Status flags (`#vf_macro.returned`, `#vf_macro.if_success`) |

## License

Unlicense — Public Domain.
