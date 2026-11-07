# macroengine:core/internal/text/to_string
# INPUT  macroengine:text: in (any value)    OUTPUT macroengine:text: out (string)   or err
# RETURN 1 on success, 0 on failure.
data remove storage macroengine:text err
data remove storage macroengine:text out
execute unless data storage macroengine:text in run data modify storage macroengine:text err set value "to_string: no input"
execute unless data storage macroengine:text in run return 0
data modify storage macroengine:text out set string storage macroengine:text in
return 1
