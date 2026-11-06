# macroengine:core/lib/string/to_number
# Input:  macroengine:input string — numeric string (e.g. "42" or "3.14")
# Output: macroengine:output string.result — numeric NBT value
# Dep:    macroengine:core/internal/text (in-house)
# On failure (e.g. the string contains a quote or backslash) string.result is left unset.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text s set from storage macroengine:input string
function macroengine:core/internal/text/to_number
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
