# macroengine:core/internal/api/block/_reg_store [INTERNAL, MACRO: id]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine block_registry."$(id)" set from storage macroengine:block tmp.reg
return 1
