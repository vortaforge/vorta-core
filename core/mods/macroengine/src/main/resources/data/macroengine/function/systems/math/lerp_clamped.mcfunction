execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $lc_a macroengine.tmp $(a)
$scoreboard players set $lc_b macroengine.tmp $(b)
$scoreboard players set $lc_t macroengine.tmp $(t)

execute if score $lc_t macroengine.tmp matches ..-1 run scoreboard players set $lc_t macroengine.tmp 0
scoreboard players set $lc_100 macroengine.tmp 100
execute if score $lc_t macroengine.tmp > $lc_100 macroengine.tmp run scoreboard players operation $lc_t macroengine.tmp = $lc_100 macroengine.tmp

scoreboard players operation $lc_r macroengine.tmp = $lc_b macroengine.tmp
scoreboard players operation $lc_r macroengine.tmp -= $lc_a macroengine.tmp

scoreboard players operation $lc_r macroengine.tmp *= $lc_t macroengine.tmp
scoreboard players operation $lc_r macroengine.tmp /= $lc_100 macroengine.tmp
scoreboard players operation $lc_r macroengine.tmp += $lc_a macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $lc_r macroengine.tmp
