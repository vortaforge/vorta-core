execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine events.$(event) run return 0

$data modify storage macroengine:engine _event_tmp set from storage macroengine:engine events.$(event)
execute if data storage macroengine:engine _event_tmp[0] run function macroengine:core/internal/events/fire_next
data remove storage macroengine:engine _event_tmp
