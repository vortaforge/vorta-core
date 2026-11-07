# macroengine:core/internal/text/split
# INPUT  macroengine:text: s, sep (strings; "" splits into characters),
#          n (int, optional: 0 all, +n first n separators, -n last n separators),
#          keep_empty (byte, optional, default 0b)
# OUTPUT macroengine:text: out (list of strings)
# RETURN number of entries in out. Splitting "" yields [""].
data remove storage macroengine:text err
data modify storage macroengine:text out set value []
execute unless data storage macroengine:text n run data modify storage macroengine:text n set value 0
execute store result score #tx_keep macroengine.tmp run data get storage macroengine:text keep_empty
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute if score #tx_len macroengine.tmp matches 0 run data modify storage macroengine:text out set value [""]
execute if score #tx_len macroengine.tmp matches 0 run return 1
execute store result score #tx_slen macroengine.tmp run data get storage macroengine:text sep
execute if score #tx_slen macroengine.tmp matches 0 run scoreboard players set #tx_i macroengine.tmp 0
execute if score #tx_slen macroengine.tmp matches 0 run function macroengine:core/internal/text/split_chars
execute if score #tx_slen macroengine.tmp matches 0 run return run data get storage macroengine:text out
data modify storage macroengine:text needle set from storage macroengine:text sep
execute store result score #tx_total macroengine.tmp run function macroengine:core/internal/text/find
scoreboard players set #tx_pos macroengine.tmp 0
function macroengine:core/internal/text/split_loop
scoreboard players operation #tx_a macroengine.tmp = #tx_pos macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_len macroengine.tmp
function macroengine:core/internal/text/_cut_ab
function macroengine:core/internal/text/split_emit
return run data get storage macroengine:text out
