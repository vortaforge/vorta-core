execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $lg2_v macroengine.tmp $(value)

execute if score $lg2_v macroengine.tmp matches ..0 run data modify storage macroengine:output result set value -1
execute if score $lg2_v macroengine.tmp matches ..0 run return 0

scoreboard players set $lg2_r macroengine.tmp 0
scoreboard players set $lg2_2 macroengine.tmp 2

function macroengine:core/internal/systems/math/log2_loop

execute store result storage macroengine:output result int 1 run scoreboard players get $lg2_r macroengine.tmp
