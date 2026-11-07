# macroengine:core/internal/text/concat
# INPUT  macroengine:text: list (list of strings; numbers are converted)
# OUTPUT macroengine:text: out (string)   on failure: err, out unset
# RETURN 1 on success, 0 on failure.
data remove storage macroengine:text err
data remove storage macroengine:text out
data modify storage macroengine:text pc set value []
data remove storage macroengine:text cl
data modify storage macroengine:text cl set from storage macroengine:text list
execute store result score #tx_r macroengine.tmp run function macroengine:core/internal/text/concat_loop
execute if data storage macroengine:text err run return 0
function macroengine:core/internal/text/join
return 1
