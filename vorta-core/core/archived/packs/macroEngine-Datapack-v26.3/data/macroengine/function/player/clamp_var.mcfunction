execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute store result score $cv macroengine.tmp run data get storage macroengine:engine players.$(player).$(key)
$scoreboard players set $cv_mn macroengine.tmp $(min)
$scoreboard players set $cv_mx macroengine.tmp $(max)
execute if score $cv macroengine.tmp < $cv_mn macroengine.tmp run scoreboard players operation $cv macroengine.tmp = $cv_mn macroengine.tmp
execute if score $cv macroengine.tmp > $cv_mx macroengine.tmp run scoreboard players operation $cv macroengine.tmp = $cv_mx macroengine.tmp
$execute store result storage macroengine:engine players.$(player).$(key) int 1 run scoreboard players get $cv macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $cv macroengine.tmp
