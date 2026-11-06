# ======================================================================================
# macroengine:core/internal/ext/events/has_func [MACRO] [INTERNAL]
# $(event), $(func) validated by events/has_func.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine events.$(event)[{func:"$(func)"}] run return 0
data modify storage macroengine:output result set value 1b
return 1
