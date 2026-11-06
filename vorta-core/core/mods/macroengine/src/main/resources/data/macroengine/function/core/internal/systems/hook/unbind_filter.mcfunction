# macroengine:systems/hook/internal/unbind_filter
# Iterates over the _hook_unbinds list.
# Copies back binds that do not match _hook_filter_event to hook_binds.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _hook_unbinds[0] run return 0

data modify storage macroengine:engine _hook_unbinds[0] set from storage macroengine:engine _hook_unbinds[0]

function macroengine:core/internal/systems/hook/unbind_check with storage macroengine:engine _hook_unbinds[0]

data remove storage macroengine:engine _hook_unbinds[0]

function macroengine:core/internal/systems/hook/unbind_filter
