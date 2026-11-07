# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run_func
# Run function list
#
# INPUT (storage macroengine:input):
# list → function list ["pack:func1", "pack:func2"]
# ─────────────────────────────────────────────────────────────────

# Convert strings to {func:"..."} format
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.run_func"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
data modify storage macroengine:engine _mcmd_queue set value []
function macroengine:core/internal/api/cmd/other/multi_cmd/func_convert_loop

data modify storage macroengine:engine _mcmd_options set value {error_mode:"continue",profile:0b,spread:0}
function macroengine:api/cmd/other/multi_cmd/run

data remove storage macroengine:engine _mcmd_func_tmp
