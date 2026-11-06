# macroengine:api/container/slot_set
# Writes an item into one slot (replaces what was there).
#
# INPUT  macroengine:input x, y, z, slot, item {id:"minecraft:stone", count:1..99 (default 1), components:{...}}
# OUTPUT macroengine:output container {ok}
# RETURN 1 on success, 0 on bad input or a block without an inventory.
# The item compound is stored as data, it is never pasted into a command. Use a real item id:
# the game decides at load time whether the entry is valid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
return run function macroengine:core/internal/api/container/slot_set_do
