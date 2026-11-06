execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute store result score $pvar macroengine.tmp run data get storage macroengine:engine players.$(player).$(key)
scoreboard players remove $pvar macroengine.tmp 1
$execute store result storage macroengine:engine players.$(player).$(key) int 1 run scoreboard players get $pvar macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $pvar macroengine.tmp
