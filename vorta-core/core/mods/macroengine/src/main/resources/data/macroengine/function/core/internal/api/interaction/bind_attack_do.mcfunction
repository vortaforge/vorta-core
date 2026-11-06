# macroengine:api/interaction/internal/bind_attack_do [MACRO] [INTERNAL]
# Called by bind_attack with storage macroengine:input {} to do the actual append.
# INPUT: $(tag), $(func)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine interaction_binds.attack append value {tag:"$(tag)", func:"$(func)"}