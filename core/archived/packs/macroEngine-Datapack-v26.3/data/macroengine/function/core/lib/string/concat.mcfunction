# macroengine:core/lib/string/concat
# Input:  macroengine:input list   — list of strings to concatenate
# Output: macroengine:output string.result — combined string
# Dep:    macroengine:core/internal/text (in-house)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text list set from storage macroengine:input list
function macroengine:core/internal/text/concat
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
