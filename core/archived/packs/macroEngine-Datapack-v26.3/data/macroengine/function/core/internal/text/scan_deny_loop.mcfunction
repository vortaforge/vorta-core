# macroengine:core/internal/text/scan_deny_loop [INTERNAL]
scoreboard players operation #tx_a macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_i macroengine.tmp
scoreboard players add #tx_b macroengine.tmp 1
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text mp set value {}
data modify storage macroengine:text mp.t set from storage macroengine:text tbl
data modify storage macroengine:text mp.c set from storage macroengine:text win
function macroengine:core/internal/text/_deny_probe with storage macroengine:text mp
execute if score #tx_hit macroengine.tmp matches 1 run return 1
scoreboard players add #tx_i macroengine.tmp 1
execute if score #tx_i macroengine.tmp < #tx_len macroengine.tmp run function macroengine:core/internal/text/scan_deny_loop
