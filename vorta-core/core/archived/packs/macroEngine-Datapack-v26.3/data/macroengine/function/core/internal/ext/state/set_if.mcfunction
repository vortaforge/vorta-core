# ======================================================================================
# macroengine:core/internal/ext/state/set_if [MACRO] [INTERNAL]
# $(player), $(from), $(to) validated by core/state/set_if.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine {states:{$(player):"$(from)"}} run return 0
$data modify storage macroengine:engine states.$(player) set value "$(to)"
data modify storage macroengine:output result set value 1b
return 1
