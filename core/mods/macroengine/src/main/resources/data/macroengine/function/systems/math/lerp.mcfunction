execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $lerp_a macroengine.tmp $(a)
$scoreboard players set $lerp_b macroengine.tmp $(b)
$scoreboard players set $lerp_t macroengine.tmp $(t)

scoreboard players operation $lerp_r macroengine.tmp = $lerp_b macroengine.tmp
scoreboard players operation $lerp_r macroengine.tmp -= $lerp_a macroengine.tmp

scoreboard players operation $lerp_r macroengine.tmp *= $lerp_t macroengine.tmp
scoreboard players set $lerp_100 macroengine.tmp 100
scoreboard players operation $lerp_r macroengine.tmp /= $lerp_100 macroengine.tmp
scoreboard players operation $lerp_r macroengine.tmp += $lerp_a macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $lerp_r macroengine.tmp
