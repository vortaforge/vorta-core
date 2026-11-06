execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $abs_v macroengine.tmp $(value)
scoreboard players set $abs_neg macroengine.tmp -1
execute if score $abs_v macroengine.tmp matches ..-1 run scoreboard players operation $abs_v macroengine.tmp *= $abs_neg macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $abs_v macroengine.tmp
