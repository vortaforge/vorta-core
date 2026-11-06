execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $ftgl macroengine.tmp 0
$execute if data storage macroengine:engine flags.$(key) run scoreboard players set $ftgl macroengine.tmp 1

$execute if score $ftgl macroengine.tmp matches 1 run data remove storage macroengine:engine flags.$(key)
execute if score $ftgl macroengine.tmp matches 1 run data modify storage macroengine:output result set value 0b

$execute if score $ftgl macroengine.tmp matches 0 run data modify storage macroengine:engine flags.$(key) set value 1b
execute if score $ftgl macroengine.tmp matches 0 run data modify storage macroengine:output result set value 1b
