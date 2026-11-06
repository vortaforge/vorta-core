# macroengine:systems/hook/internal/fire [MACRO]
# INPUT: $(event) — event name to fire
# @s = the triggering player
# Copies hook_binds list and dispatches it.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _hook_fire_event set value "$(event)"
data modify storage macroengine:engine _hook_iter set from storage macroengine:engine hook_binds

execute if data storage macroengine:engine _hook_iter run function macroengine:core/internal/systems/hook/dispatch

data remove storage macroengine:engine _hook_iter
data remove storage macroengine:engine _hook_fire_event
