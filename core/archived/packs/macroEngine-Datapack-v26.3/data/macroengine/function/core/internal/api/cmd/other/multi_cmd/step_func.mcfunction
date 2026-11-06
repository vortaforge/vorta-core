execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _mcmd_list[0] run return 0

data modify storage macroengine:engine _mcmd_entry set value {}
data modify storage macroengine:engine _mcmd_entry.current_cmd set from storage macroengine:engine _mcmd_list[0]
data remove storage macroengine:engine _mcmd_list[0]

function macroengine:core/internal/api/cmd/other/multi_cmd/exec_func with storage macroengine:engine _mcmd_entry

function macroengine:core/internal/api/cmd/other/multi_cmd/step_func
