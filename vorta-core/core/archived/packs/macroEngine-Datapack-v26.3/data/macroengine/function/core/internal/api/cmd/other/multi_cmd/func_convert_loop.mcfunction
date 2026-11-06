# Convert string list to {func:"..."} objects
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input list[0] run return 0

data modify storage macroengine:engine _mcmd_func_tmp set value {}
data modify storage macroengine:engine _mcmd_func_tmp.func set from storage macroengine:input list[0]
data modify storage macroengine:engine _mcmd_queue append from storage macroengine:engine _mcmd_func_tmp

data remove storage macroengine:input list[0]
function macroengine:core/internal/api/cmd/other/multi_cmd/func_convert_loop
