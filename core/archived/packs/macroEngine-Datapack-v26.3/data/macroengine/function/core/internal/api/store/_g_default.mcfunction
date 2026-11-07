# macroengine:core/internal/api/store/_g_default [MACRO] [INTERNAL]
$execute if data storage macroengine:store g.$(name) run return 0
$data modify storage macroengine:store g.$(name) set from storage macroengine:store in.value
return 1
