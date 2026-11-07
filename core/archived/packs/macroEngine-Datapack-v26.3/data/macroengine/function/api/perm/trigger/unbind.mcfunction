execute if data storage macroengine:engine modules{perm:0b} run return 0
$execute unless data storage macroengine:engine perm_triggers.$(name) run return 0

$data modify storage macroengine:engine _pt_unbind set from storage macroengine:engine perm_triggers.$(name)
$data modify storage macroengine:engine perm_triggers.$(name) set value []
$data modify storage macroengine:engine _pt_uval set value $(value)
$data modify storage macroengine:engine _pt_filter_ctx set value {name:"$(name)"}

function macroengine:core/internal/api/perm/trigger/unbind_filter

data remove storage macroengine:engine _pt_unbind
data remove storage macroengine:engine _pt_uval
data remove storage macroengine:engine _pt_filter_ctx