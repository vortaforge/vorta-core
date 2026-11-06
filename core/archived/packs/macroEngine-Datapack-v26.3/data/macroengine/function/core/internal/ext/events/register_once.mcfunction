# ======================================================================================
# macroengine:core/internal/ext/events/register_once [MACRO] [INTERNAL]
# $(event), $(func) validated by events/register_once.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine events.$(event)[{func:"$(func)"}] run return 0
$data modify storage macroengine:engine events.$(event) append value {func:"$(func)"}
data modify storage macroengine:output result set value 1b
return 1
