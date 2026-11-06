# macroengine:api/container/slot_is_empty
# Condition: is this slot empty?
# INPUT  macroengine:input x, y, z, slot
# RETURN 1 when the block is a container and the slot is empty, else 0.
# OUTPUT macroengine:output container {ok} tells a real container from a bad input.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
function macroengine:core/internal/api/container/slot_get_do
execute if data storage macroengine:output container{ok:1b,empty:1b} run return 1
return 0
