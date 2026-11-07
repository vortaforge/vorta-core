# ======================================================================================
# macroengine:core/internal/ext/state/set_if [MACRO] [INTERNAL]
# $(player), $(from), $(to) validated by core/state/set_if.
# ======================================================================================

$execute unless data storage macroengine:engine {states:{$(player):"$(from)"}} run return 0
$data modify storage macroengine:engine states.$(player) set value "$(to)"
data modify storage macroengine:output result set value 1b
return 1
