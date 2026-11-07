# macroengine:core/internal/text/replace
# INPUT  macroengine:text: s, needle, rep (strings), n (int, optional: 0 all, +n first n, -n last n)
# OUTPUT macroengine:text: out (string)   on failure: err, out unset
# RETURN number of replacements. s and rep must not contain a quote or backslash.
data remove storage macroengine:text err
data remove storage macroengine:text out
execute unless data storage macroengine:text n run data modify storage macroengine:text n set value 0
data modify storage macroengine:text r set value {}
data modify storage macroengine:text r.s set from storage macroengine:text s
data modify storage macroengine:text r.needle set from storage macroengine:text needle
data modify storage macroengine:text r.rep set from storage macroengine:text rep
data modify storage macroengine:text r.n set from storage macroengine:text n
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "replace: the string contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:text r.rep
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/safe
data modify storage macroengine:text s set from storage macroengine:text r.s
execute if score #tx_ok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "replace: the replacement contains a quote or backslash"
execute if score #tx_ok macroengine.tmp matches 0 run return 0
data modify storage macroengine:text needle set from storage macroengine:text r.needle
data modify storage macroengine:text n set from storage macroengine:text r.n
execute store result score #tx_total macroengine.tmp run function macroengine:core/internal/text/find
execute if score #tx_total macroengine.tmp matches 0 run data modify storage macroengine:text out set from storage macroengine:text r.s
execute if score #tx_total macroengine.tmp matches 0 run return 0
data modify storage macroengine:text pc set value []
scoreboard players set #tx_pos macroengine.tmp 0
function macroengine:core/internal/text/replace_loop
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
scoreboard players operation #tx_a macroengine.tmp = #tx_pos macroengine.tmp
scoreboard players operation #tx_b macroengine.tmp = #tx_len macroengine.tmp
function macroengine:core/internal/text/_cut_ab
data modify storage macroengine:text pc append from storage macroengine:text win
function macroengine:core/internal/text/join
return run scoreboard players get #tx_total macroengine.tmp
