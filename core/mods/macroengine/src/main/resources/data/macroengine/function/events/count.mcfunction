execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output result set value 0
$execute if data storage macroengine:engine events.$(event) run execute store result storage macroengine:output result int 1 run data get storage macroengine:engine events.$(event)
