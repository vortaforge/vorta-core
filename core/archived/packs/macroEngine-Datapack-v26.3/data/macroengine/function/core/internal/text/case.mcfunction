# macroengine:core/internal/text/case [INTERNAL] maps every character of s through table macroengine:text tbl
data remove storage macroengine:text err
data remove storage macroengine:text out
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute if score #tx_len macroengine.tmp matches 0 run data modify storage macroengine:text out set value ""
execute if score #tx_len macroengine.tmp matches 0 run return 1
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "case: the string contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text pc set value []
scoreboard players set #tx_i macroengine.tmp 0
function macroengine:core/internal/text/case_loop
function macroengine:core/internal/text/join
return 1
