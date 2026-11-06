execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $inv_cnt macroengine.tmp 0
$execute as @a[name=$(player),limit=1] run execute store result score $inv_cnt macroengine.tmp run clear @s *[minecraft:custom_data=$(customData)] 0
execute store result storage macroengine:output count int 1 run scoreboard players get $inv_cnt macroengine.tmp
