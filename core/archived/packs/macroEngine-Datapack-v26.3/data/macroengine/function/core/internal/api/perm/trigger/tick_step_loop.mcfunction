execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _pt_names_tmp[0] run return 0

data modify storage macroengine:engine _pt_tick_ctx set from storage macroengine:engine _pt_names_tmp[0]
data remove storage macroengine:engine _pt_names_tmp[0]

function macroengine:core/internal/api/perm/trigger/tick_dispatch with storage macroengine:engine _pt_tick_ctx

function macroengine:core/internal/api/perm/trigger/tick_step_loop
