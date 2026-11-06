# macroengine:core/internal/text/join_round [INTERNAL] one reduction round, repeats until one entry is left
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text nl set value []
function macroengine:core/internal/text/join_take
data modify storage macroengine:text pc set from storage macroengine:text nl
execute if data storage macroengine:text pc[1] run function macroengine:core/internal/text/join_round
