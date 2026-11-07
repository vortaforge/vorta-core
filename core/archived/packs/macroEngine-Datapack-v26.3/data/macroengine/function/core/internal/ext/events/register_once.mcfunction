# ======================================================================================
# macroengine:core/internal/ext/events/register_once [MACRO] [INTERNAL]
# $(event), $(func) validated by events/register_once.
# ======================================================================================

$execute if data storage macroengine:engine events.$(event)[{func:"$(func)"}] run return 0
$data modify storage macroengine:engine events.$(event) append value {func:"$(func)"}
data modify storage macroengine:output result set value 1b
return 1
