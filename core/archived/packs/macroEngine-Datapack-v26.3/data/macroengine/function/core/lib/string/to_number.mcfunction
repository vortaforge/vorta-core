# macroengine:core/lib/string/to_number
# Input:  macroengine:input string — numeric string (e.g. "42" or "3.14")
# Output: macroengine:output string.result — numeric NBT value
# Dep:    macroengine:core/internal/text (in-house)
# On failure (e.g. the string contains a quote or backslash) string.result is left unset.
data modify storage macroengine:text s set from storage macroengine:input string
function macroengine:core/internal/text/to_number
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
