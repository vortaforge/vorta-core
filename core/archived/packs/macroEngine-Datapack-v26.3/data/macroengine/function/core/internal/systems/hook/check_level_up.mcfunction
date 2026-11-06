execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score $hlvl_cur macroengine.tmp run data get entity @s XpLevel
execute if score @s macroengine.hook_lvl < $hlvl_cur macroengine.tmp run scoreboard players operation @s macroengine.hook_lvl_new = $hlvl_cur macroengine.tmp
execute if score @s macroengine.hook_lvl < $hlvl_cur macroengine.tmp run function macroengine:core/internal/systems/hook/on_level_up
execute store result score @s macroengine.hook_lvl run scoreboard players get $hlvl_cur macroengine.tmp
