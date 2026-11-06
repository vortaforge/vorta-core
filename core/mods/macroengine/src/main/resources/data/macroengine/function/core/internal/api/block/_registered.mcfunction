# macroengine:core/internal/api/block/_registered [INTERNAL, MACRO: id]
# RETURN 1 when block_registry has this id.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine block_registry."$(id)" run return 1
return 0
