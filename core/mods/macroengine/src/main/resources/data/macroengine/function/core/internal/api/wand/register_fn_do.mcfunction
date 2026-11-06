# macroengine:api/wand/internal/register_fn_do [MACRO] [INTERNAL]
# Called by wand/register_fn with storage macroengine:input {} to do the actual append.
# INPUT: $(tag), $(func)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine wand_binds append value {tag:"$(tag)", func:"$(func)"}