# macroengine:core/lib/string/insert
# Input:  macroengine:input string    — original string
#         macroengine:input insertion — string to insert
#         macroengine:input index     — insertion position (integer)
# Output: macroengine:output string.result — resulting string
# Dep:    macroengine:core/internal/text (in-house)
# On failure (e.g. the string contains a quote or backslash) string.result is left unset.
data modify storage macroengine:text s set from storage macroengine:input string
data modify storage macroengine:text ins set from storage macroengine:input insertion
data modify storage macroengine:text at set from storage macroengine:input index
function macroengine:core/internal/text/insert
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
