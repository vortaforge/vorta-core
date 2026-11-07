# macroengine:core/lib/string/to_string
# Input:  macroengine:input value — numeric or any SNBT value to stringify
# Output: macroengine:output string.result — string representation
# Note:   Prefer 'data modify ... set string storage ...' when possible (cheaper)
# Dep:    macroengine:core/internal/text (in-house)
data modify storage macroengine:text in set from storage macroengine:input value
function macroengine:core/internal/text/to_string
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
