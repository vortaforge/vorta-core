# macroengine:core/internal/text/split_chars [INTERNAL] one entry per character
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation #tx_a macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_i macroengine.tmp
scoreboard players add #tx_b macroengine.tmp 1
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text out append from storage macroengine:text win
scoreboard players add #tx_i macroengine.tmp 1
execute if score #tx_i macroengine.tmp < #tx_len macroengine.tmp run function macroengine:core/internal/text/split_chars
