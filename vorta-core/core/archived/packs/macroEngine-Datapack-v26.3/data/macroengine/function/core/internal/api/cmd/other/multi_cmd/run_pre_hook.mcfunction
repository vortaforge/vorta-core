# Pre-hook runner
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/hook_pre_exec with storage macroengine:engine _mcmd_current
