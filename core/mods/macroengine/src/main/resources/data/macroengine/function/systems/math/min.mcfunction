execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $min_a macroengine.tmp $(a)
$scoreboard players set $min_b macroengine.tmp $(b)

execute store result storage macroengine:output result int 1 run scoreboard players get $min_a macroengine.tmp

execute if score $min_b macroengine.tmp < $min_a macroengine.tmp run execute store result storage macroengine:output result int 1 run scoreboard players get $min_b macroengine.tmp
