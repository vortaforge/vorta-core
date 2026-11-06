execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score $ce_base macroengine.tmp run scoreboard players get $epoch macroengine.time
scoreboard players operation $ce_exp macroengine.tmp = $ce_base macroengine.tmp

$execute if data storage macroengine:engine cooldowns.$(player).$(key) run execute store result score $ce_exp macroengine.tmp run data get storage macroengine:engine cooldowns.$(player).$(key)

execute if score $ce_exp macroengine.tmp <= $ce_base macroengine.tmp run scoreboard players operation $ce_exp macroengine.tmp = $ce_base macroengine.tmp

$scoreboard players set $ce_amt macroengine.tmp $(amount)
scoreboard players operation $ce_exp macroengine.tmp += $ce_amt macroengine.tmp

$execute store result storage macroengine:engine cooldowns.$(player).$(key) int 1 run scoreboard players get $ce_exp macroengine.tmp