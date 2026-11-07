# macroengine:core/lib/string/concat
# Input:  macroengine:input list   — list of strings to concatenate
# Output: macroengine:output string.result — combined string
# Dep:    macroengine:core/internal/text (in-house)
data modify storage macroengine:text list set from storage macroengine:input list
function macroengine:core/internal/text/concat
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
