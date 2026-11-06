# macroengine:systems/hook/internal/unbind_exec [MACRO]
# INPUT: $(event)
# Filters all binds belonging to $(event) from hook_binds.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _hook_unbinds set from storage macroengine:engine hook_binds
data modify storage macroengine:engine hook_binds set value []
$data modify storage macroengine:engine _hook_filter_event set value "$(event)"
function macroengine:core/internal/systems/hook/unbind_filter

data remove storage macroengine:engine _hook_unbinds
data remove storage macroengine:engine _hook_filter_event