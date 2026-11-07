# macroengine:core/internal/text/replace_loop [INTERNAL] emits "text before match" + replacement per match
execute unless data storage macroengine:text idx[0] run return 0
execute store result score #tx_k macroengine.tmp run data get storage macroengine:text idx[0]
scoreboard players operation #tx_a macroengine.tmp = #tx_pos macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_k macroengine.tmp
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
data modify storage macroengine:text pc append from storage macroengine:text r.rep
scoreboard players operation #tx_pos macroengine.tmp = #tx_k macroengine.tmp
scoreboard players operation #tx_pos macroengine.tmp += #tx_nlen macroengine.tmp
data remove storage macroengine:text idx[0]
function macroengine:core/internal/text/replace_loop
