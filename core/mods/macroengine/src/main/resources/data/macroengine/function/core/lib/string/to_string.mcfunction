# macroengine:core/lib/string/to_string
# Input:  macroengine:input value — numeric or any SNBT value to stringify
# Output: macroengine:output string.result — string representation
# Note:   Prefer 'data modify ... set string storage ...' when possible (cheaper)
# Dep:    macroengine:core/internal/text (in-house)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text in set from storage macroengine:input value
function macroengine:core/internal/text/to_string
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
