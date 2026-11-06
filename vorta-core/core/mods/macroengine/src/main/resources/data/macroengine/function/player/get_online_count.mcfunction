execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $poc macroengine.tmp 0
execute as @a run scoreboard players add $poc macroengine.tmp 1
execute store result storage macroengine:output result int 1 run scoreboard players get $poc macroengine.tmp
