# macroengine:core/internal/text/to_number
# INPUT  macroengine:text: s (string like "42", "-7", "3.14")
# OUTPUT macroengine:text: out (int or double)   on failure: err, out unset
# RETURN 1 on success, 0 on failure. Whole numbers are limited to 9 digits.
data remove storage macroengine:text out
data modify storage macroengine:text allow_dot set value 1b
execute store result score #tx_ok macroengine.tmp run function macroengine:core/internal/text/num_check
execute if score #tx_ok macroengine.tmp matches 0 run return 0
scoreboard players operation #tx_digits macroengine.tmp = #tx_len macroengine.tmp
scoreboard players operation #tx_digits macroengine.tmp -= #tx_start macroengine.tmp
execute if score #tx_dots macroengine.tmp matches 0 if score #tx_digits macroengine.tmp matches 10.. run data modify storage macroengine:text err set value "to_number: whole numbers are limited to 9 digits"
execute if score #tx_dots macroengine.tmp matches 1 if score #tx_digits macroengine.tmp matches 18.. run data modify storage macroengine:text err set value "to_number: too many digits"
execute if data storage macroengine:text err run return 0
data modify storage macroengine:text arg set value {}
data modify storage macroengine:text arg.s set from storage macroengine:text s
function macroengine:core/internal/text/_num_emit with storage macroengine:text arg
return 1
