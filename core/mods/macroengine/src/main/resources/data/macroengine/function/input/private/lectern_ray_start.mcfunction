# ======================================================================================
# macroengine:input/private/lectern_ray_start  [INTERNAL]
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set @s macroengine.tmp 0
execute anchored eyes positioned ^ ^ ^0.1 run function macroengine:input/private/lectern_ray_loop
