# macroengine:core/internal/text/to_string
# INPUT  macroengine:text: in (any value)    OUTPUT macroengine:text: out (string)   or err
# RETURN 1 on success, 0 on failure.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:text err
data remove storage macroengine:text out
execute unless data storage macroengine:text in run data modify storage macroengine:text err set value "to_string: no input"
execute unless data storage macroengine:text in run return 0
data modify storage macroengine:text out set string storage macroengine:text in
return 1
