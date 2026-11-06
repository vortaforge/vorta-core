execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine events.$(event) run return 0

$data modify storage macroengine:engine _uro.event set value "$(event)"
$data modify storage macroengine:engine _uro.func set value "$(func)"
$data modify storage macroengine:engine _uro.src set from storage macroengine:engine events.$(event)

$data remove storage macroengine:engine events.$(event)

execute if data storage macroengine:engine _uro.src[0] run function macroengine:core/internal/events/uro_loop

data remove storage macroengine:engine _uro
