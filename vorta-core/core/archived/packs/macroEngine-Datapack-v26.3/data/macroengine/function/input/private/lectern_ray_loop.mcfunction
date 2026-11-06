# ======================================================================================
# macroengine:input/private/lectern_ray_loop  [INTERNAL]
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if block ~ ~ ~ minecraft:lectern run return run function macroengine:input/private/lectern_capture

scoreboard players add @s macroengine.tmp 1
execute if score @s macroengine.tmp matches 50.. run return 0
execute positioned ^ ^ ^0.1 run function macroengine:input/private/lectern_ray_loop
