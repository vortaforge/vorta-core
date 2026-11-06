execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $mmx_a macroengine.tmp $(a)
$scoreboard players set $mmx_b macroengine.tmp $(b)

scoreboard players operation $mmx_lo macroengine.tmp = $mmx_a macroengine.tmp
execute if score $mmx_b macroengine.tmp < $mmx_a macroengine.tmp run scoreboard players operation $mmx_lo macroengine.tmp = $mmx_b macroengine.tmp

scoreboard players operation $mmx_hi macroengine.tmp = $mmx_a macroengine.tmp
execute if score $mmx_b macroengine.tmp > $mmx_a macroengine.tmp run scoreboard players operation $mmx_hi macroengine.tmp = $mmx_b macroengine.tmp

execute store result storage macroengine:output min int 1 run scoreboard players get $mmx_lo macroengine.tmp
execute store result storage macroengine:output max int 1 run scoreboard players get $mmx_hi macroengine.tmp
