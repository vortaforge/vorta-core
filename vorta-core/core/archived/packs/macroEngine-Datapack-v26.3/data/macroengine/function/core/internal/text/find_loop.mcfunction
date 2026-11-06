# macroengine:core/internal/text/find_loop [INTERNAL] one window comparison per call
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #tx_a macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp += #tx_nlen macroengine.tmp
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text cmp set from storage macroengine:text win
execute store success score #tx_diff macroengine.tmp run data modify storage macroengine:text cmp set from storage macroengine:text needle
execute if score #tx_diff macroengine.tmp matches 0 run function macroengine:core/internal/text/find_hit
execute if score #tx_diff macroengine.tmp matches 1 run scoreboard players add #tx_i macroengine.tmp 1
execute if score #tx_cap macroengine.tmp matches 1.. if score #tx_hits macroengine.tmp >= #tx_cap macroengine.tmp run return 0
execute if score #tx_i macroengine.tmp <= #tx_last macroengine.tmp run function macroengine:core/internal/text/find_loop
