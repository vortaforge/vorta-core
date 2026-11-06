execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute as @s at @s anchored eyes positioned ^ ^ ^0.0 run tp @e[type=minecraft:command_block_minecart,tag=macroengine_input,distance=..5,sort=nearest,limit=1] ~ ~-0.23 ~
