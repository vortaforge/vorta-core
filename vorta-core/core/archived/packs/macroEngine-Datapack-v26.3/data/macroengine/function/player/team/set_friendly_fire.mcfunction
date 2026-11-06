execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$team modify $(team) friendlyFire $(value)
$data modify storage macroengine:engine teams.$(team).friendly_fire set value "$(value)"
