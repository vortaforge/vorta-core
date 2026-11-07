# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/from_input_as
# Execute as a specific selector
#
# INPUT (storage macroengine:input):
# list → command list
# selector → entity selector (default: @s)
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.from_input_as"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
execute unless data storage macroengine:input selector run data modify storage macroengine:input selector set value "@s"

data modify storage macroengine:engine _mcmd_queue set from storage macroengine:input list
data modify storage macroengine:engine _mcmd_options set value {error_mode:"continue",profile:0b,spread:0}

function macroengine:core/internal/api/cmd/other/multi_cmd/run_as_exec with storage macroengine:input
