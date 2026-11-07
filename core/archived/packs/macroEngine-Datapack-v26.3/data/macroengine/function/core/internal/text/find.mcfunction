# macroengine:core/internal/text/find
# Positions of non-overlapping occurrences of a needle in a string.
# INPUT  macroengine:text: s (string), needle (string), n (int, optional)
#          n = 0 all, n > 0 the first n, n < 0 the last |n|
# OUTPUT macroengine:text: idx (list of start indices, ascending)
# RETURN number of occurrences in idx. An empty needle matches nothing.
execute unless data storage macroengine:text n run data modify storage macroengine:text n set value 0
data modify storage macroengine:text idx set value []
scoreboard players set #tx_hits macroengine.tmp 0
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute store result score #tx_nlen macroengine.tmp run data get storage macroengine:text needle
execute store result score #tx_max macroengine.tmp run data get storage macroengine:text n
execute if score #tx_nlen macroengine.tmp matches 0 run return 0
scoreboard players operation #tx_last macroengine.tmp = #tx_len macroengine.tmp
scoreboard players operation #tx_last macroengine.tmp -= #tx_nlen macroengine.tmp
execute if score #tx_last macroengine.tmp matches ..-1 run return 0
scoreboard players set #tx_cap macroengine.tmp 0
execute if score #tx_max macroengine.tmp matches 1.. run scoreboard players operation #tx_cap macroengine.tmp = #tx_max macroengine.tmp
scoreboard players set #tx_i macroengine.tmp 0
function macroengine:core/internal/text/find_loop
execute if score #tx_max macroengine.tmp matches ..-1 run function macroengine:core/internal/text/find_trim
return run scoreboard players get #tx_hits macroengine.tmp
