# macroengine:api/container/slot_get
# Reads one slot of a container block.
#
# INPUT  macroengine:input x, y, z (ints, absolute), slot (int 0..255)
# OUTPUT macroengine:output container {ok:1b if the block is a container, empty:1b/0b, item:{...}}
#        container.item is the raw item entry (id, count, components, Slot), only when not empty.
# RETURN 1 when the block is a container, else 0 (bad input, not loaded, no inventory).
# Numbers are read as numbers; a string in x/y/z/slot is rejected before any macro line.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
return run function macroengine:core/internal/api/container/slot_get_do
