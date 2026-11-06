# macroengine:core/internal/text/split_loop [INTERNAL] one segment per separator match
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:text idx[0] run return 0
execute store result score #tx_k macroengine.tmp run data get storage macroengine:text idx[0]
scoreboard players operation #tx_a macroengine.tmp = #tx_pos macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_k macroengine.tmp
function macroengine:core/internal/text/_cut_ab
function macroengine:core/internal/text/split_emit
scoreboard players operation #tx_pos macroengine.tmp = #tx_k macroengine.tmp
scoreboard players operation #tx_pos macroengine.tmp += #tx_slen macroengine.tmp
data remove storage macroengine:text idx[0]
function macroengine:core/internal/text/split_loop
