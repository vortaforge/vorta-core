# macroengine:api/cmd/other/multi_cmd/advanced/run_with_options
# Run with advanced options.
#
# INPUT (storage macroengine:input):
#   list    → command list (string or object)
#   options → {priority_sort:1b, spread_ticks:0, error_mode:"continue", profile:1b, type:"..."}
#

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.advanced.run_with_options"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
data modify storage macroengine:engine _mcmd_queue set from storage macroengine:input list
execute unless data storage macroengine:input options run data modify storage macroengine:input options set value {}
data modify storage macroengine:engine _mcmd_options merge from storage macroengine:input options

execute unless data storage macroengine:engine _mcmd_options.error_mode run data modify storage macroengine:engine _mcmd_options.error_mode set value "continue"
execute unless data storage macroengine:engine _mcmd_options.profile run data modify storage macroengine:engine _mcmd_options.profile set value 0b
execute unless data storage macroengine:engine _mcmd_options.spread_ticks run data modify storage macroengine:engine _mcmd_options.spread_ticks set value 0

execute if data storage macroengine:engine _mcmd_options{priority_sort:1b} run function macroengine:core/internal/api/cmd/other/multi_cmd/advanced/sort_by_priority
execute if data storage macroengine:engine _mcmd_options.spread_ticks unless data storage macroengine:engine _mcmd_options{spread_ticks:0} run return run function macroengine:core/internal/api/cmd/other/multi_cmd/advanced/run_spread

function macroengine:api/cmd/other/multi_cmd/run