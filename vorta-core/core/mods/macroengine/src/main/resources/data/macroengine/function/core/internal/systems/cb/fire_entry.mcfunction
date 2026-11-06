# macroengine:systems/cb/internal/fire_entry
# Fires the command in _cb_entry via command block.
# Reuses api/cb/internal machinery.

# Copy to input storage, reuse exec path
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:input cb set from storage macroengine:engine _cb_entry
function macroengine:core/internal/api/cb/exec with storage macroengine:input cb
data remove storage macroengine:input cb
