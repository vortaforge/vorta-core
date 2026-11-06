execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $st_tog macroengine.tmp 0
$execute if data storage macroengine:engine {states:{$(player):"$(on)"}} run scoreboard players set $st_tog macroengine.tmp 1

$execute if score $st_tog macroengine.tmp matches 1 run data modify storage macroengine:engine states.$(player) set value "$(off)"
$execute if score $st_tog macroengine.tmp matches 0 run data modify storage macroengine:engine states.$(player) set value "$(on)"

data remove storage macroengine:output result
$data modify storage macroengine:output result set from storage macroengine:engine states.$(player)
