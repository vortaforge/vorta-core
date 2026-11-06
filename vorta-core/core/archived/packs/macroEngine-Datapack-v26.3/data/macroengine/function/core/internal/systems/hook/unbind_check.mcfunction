# macroengine:systems/hook/internal/unbind_check [MACRO]
# INPUT: $(event) — event field of the current bind
# If it does not match _hook_filter_event, put back into hook_binds.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine {_hook_filter_event:"$(event)"} run data modify storage macroengine:engine hook_binds append from storage macroengine:engine _hook_unbinds[0]
