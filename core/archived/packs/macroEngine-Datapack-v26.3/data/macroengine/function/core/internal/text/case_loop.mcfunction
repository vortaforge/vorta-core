# macroengine:core/internal/text/case_loop [INTERNAL] one character per call
scoreboard players operation #tx_a macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_i macroengine.tmp
scoreboard players add #tx_b macroengine.tmp 1
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text mp set value {}
data modify storage macroengine:text mp.t set from storage macroengine:text tbl
data modify storage macroengine:text mp.c set from storage macroengine:text win
data modify storage macroengine:text ch set from storage macroengine:text win
function macroengine:core/internal/text/_case_map with storage macroengine:text mp
data modify storage macroengine:text pc append from storage macroengine:text ch
scoreboard players add #tx_i macroengine.tmp 1
execute if score #tx_i macroengine.tmp < #tx_len macroengine.tmp run function macroengine:core/internal/text/case_loop
