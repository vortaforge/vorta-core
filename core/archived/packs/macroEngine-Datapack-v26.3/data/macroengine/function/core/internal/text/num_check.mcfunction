# macroengine:core/internal/text/num_check
# INPUT  macroengine:text: s, allow_dot (byte: 1b also accepts one decimal point)
# RETURN 1 when s is a whole number (or decimal), 0 otherwise with err set.
# Accepts an optional leading '-'. A '.' must have digits on both sides.
# No size limit here; to_number adds one.
data remove storage macroengine:text err
execute store result score #tx_len macroengine.tmp run data get storage macroengine:text s
execute store result score #tx_dotok macroengine.tmp run data get storage macroengine:text allow_dot
execute if score #tx_len macroengine.tmp matches 0 run data modify storage macroengine:text err set value "empty input"
execute if score #tx_len macroengine.tmp matches 0 run return 0
scoreboard players set #tx_a macroengine.tmp 0
scoreboard players set #tx_b macroengine.tmp 1
function macroengine:core/internal/text/_cut_ab
scoreboard players set #tx_start macroengine.tmp 0
execute if data storage macroengine:text {win:"-"} run scoreboard players set #tx_start macroengine.tmp 1
execute if score #tx_start macroengine.tmp >= #tx_len macroengine.tmp if score #tx_dotok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "no digits after '-'"
execute if score #tx_start macroengine.tmp >= #tx_len macroengine.tmp if score #tx_dotok macroengine.tmp matches 1 run data modify storage macroengine:text err set value "no digits"
execute if data storage macroengine:text err run return 0
data modify storage macroengine:text needle set value "."
data modify storage macroengine:text n set value 0
execute store result score #tx_dots macroengine.tmp run function macroengine:core/internal/text/find
execute if score #tx_dots macroengine.tmp matches 2.. run data modify storage macroengine:text err set value "more than one '.'"
execute if score #tx_dots macroengine.tmp matches 1 if score #tx_dotok macroengine.tmp matches 0 run data modify storage macroengine:text err set value "contains a non-digit character"
execute if data storage macroengine:text err run return 0
scoreboard players set #tx_dotpos macroengine.tmp -1
execute if score #tx_dots macroengine.tmp matches 1 store result score #tx_dotpos macroengine.tmp run data get storage macroengine:text idx[0]
scoreboard players operation #tx_last macroengine.tmp = #tx_len macroengine.tmp
scoreboard players remove #tx_last macroengine.tmp 1
execute if score #tx_dots macroengine.tmp matches 1 if score #tx_dotpos macroengine.tmp = #tx_start macroengine.tmp run data modify storage macroengine:text err set value "malformed decimal point"
execute if score #tx_dots macroengine.tmp matches 1 if score #tx_dotpos macroengine.tmp = #tx_last macroengine.tmp run data modify storage macroengine:text err set value "malformed decimal point"
execute if data storage macroengine:text err run return 0
scoreboard players operation #tx_i macroengine.tmp = #tx_start macroengine.tmp
data modify storage macroengine:text isd set value 1b
execute store result score #tx_r macroengine.tmp run function macroengine:core/internal/text/num_scan_loop
execute if score #tx_r macroengine.tmp matches 0 run data modify storage macroengine:text err set value "contains a non-digit character"
execute if score #tx_r macroengine.tmp matches 0 run return 0
return 1
