# macroengine:core/internal/text/insert
# INPUT  macroengine:text: s, ins (strings), at (int, 0..length)
# OUTPUT macroengine:text: out (string)   on failure: err, out unset
# RETURN 1 on success, 0 on failure. s and ins must not contain a quote or backslash.
data remove storage macroengine:text err
data remove storage macroengine:text out
execute unless data storage macroengine:text at run data modify storage macroengine:text at set value 0
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute store result score #tx_at macroengine.tmp run data get storage macroengine:text at
execute if score #tx_at macroengine.tmp matches ..-1 run data modify storage macroengine:text err set value "insert: index out of range"
execute if score #tx_at macroengine.tmp > #tx_len macroengine.tmp run data modify storage macroengine:text err set value "insert: index out of range"
execute if data storage macroengine:text err run return 0
data modify storage macroengine:text r set value {}
data modify storage macroengine:text r.s set from storage macroengine:text s
data modify storage macroengine:text r.ins set from storage macroengine:text ins
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "insert: the string contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:text r.ins
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
data modify storage macroengine:text s set from storage macroengine:text r.s
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "insert: the inserted text contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text pc set value []
scoreboard players set #tx_a macroengine.tmp 0
scoreboard players operation #tx_b macroengine.tmp = #tx_at macroengine.tmp
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
data modify storage macroengine:text pc append from storage macroengine:text r.ins
scoreboard players operation #tx_a macroengine.tmp = #tx_at macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_len macroengine.tmp
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
function macroengine:core/internal/text/join
return 1
