# macroengine:core/internal/text/num_scan_loop [INTERNAL] every character except the decimal point must be a digit
execute unless score #tx_i macroengine.tmp < #tx_len macroengine.tmp run return 1
execute if score #tx_i macroengine.tmp = #tx_dotpos macroengine.tmp run scoreboard players add #tx_i macroengine.tmp 1
execute unless score #tx_i macroengine.tmp < #tx_len macroengine.tmp run return 1
scoreboard players operation #tx_a macroengine.tmp = #tx_i macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_i macroengine.tmp
scoreboard players add #tx_b macroengine.tmp 1
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text mp set value {}
data modify storage macroengine:text mp.c set from storage macroengine:text win
data modify storage macroengine:text isd set value 0b
function macroengine:core/internal/text/_digit_probe with storage macroengine:text mp
execute if data storage macroengine:text {isd:0b} run return 0
scoreboard players add #tx_i macroengine.tmp 1
return run function macroengine:core/internal/text/num_scan_loop
