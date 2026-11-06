execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $ent_count macroengine.tmp 0
$execute as @e[type=$(type),tag=$(tag)] run scoreboard players add $ent_count macroengine.tmp 1
execute store result storage macroengine:output count int 1 run scoreboard players get $ent_count macroengine.tmp
