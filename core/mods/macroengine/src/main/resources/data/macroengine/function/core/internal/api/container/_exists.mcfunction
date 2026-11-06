# macroengine:core/internal/api/container/_exists [INTERNAL, MACRO: x, y, z]
# RETURN 1 when the block is a container (has an Items list), else 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data block $(x) $(y) $(z) Items run return 1
return 0
