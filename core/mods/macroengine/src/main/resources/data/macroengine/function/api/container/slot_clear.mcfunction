# macroengine:api/container/slot_clear
# Empties one slot.
# INPUT  macroengine:input x, y, z, slot
# OUTPUT macroengine:output container {ok}
# RETURN 1 on success, 0 on bad input or a block without an inventory.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
return run function macroengine:core/internal/api/container/slot_clear_do
