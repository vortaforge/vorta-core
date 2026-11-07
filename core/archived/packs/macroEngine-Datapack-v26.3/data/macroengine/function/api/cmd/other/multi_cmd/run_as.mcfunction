# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run_as
# Run queue as a specific entity
#
# INPUT (storage macroengine:input):
# selector → entity selector
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.run_as"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/run_as_exec with storage macroengine:input
