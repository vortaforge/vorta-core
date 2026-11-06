# macroengine:systems/hook/internal/dispatch
# Iterates _hook_iter list, runs matching events.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _hook_iter[0] run return 0

data modify storage macroengine:engine _hook_ctx set from storage macroengine:engine _hook_iter[0]
data remove storage macroengine:engine _hook_iter[0]

function macroengine:core/internal/systems/hook/check_bind with storage macroengine:engine _hook_ctx

function macroengine:core/internal/systems/hook/dispatch
