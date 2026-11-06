# macroengine:core/internal/text/lower
# INPUT  macroengine:text: s    OUTPUT macroengine:text: out   (or err)   RETURN 1 on success, 0 on failure
# Case mapping for ASCII letters only.
# s must not contain a quote or backslash.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text tbl set value "lower"
return run function macroengine:core/internal/text/case
