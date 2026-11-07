# macroengine:core/lib/string/replace
# Input:  macroengine:input string  — original string
#         macroengine:input find    — substring to replace
#         macroengine:input replace — replacement string
#         macroengine:input n       — instance count (0/unset=all, +n=first n, -n=last n)
# Output: macroengine:output string.result — resulting string
# Dep:    macroengine:core/internal/text (in-house)
# On failure (e.g. the string contains a quote or backslash) string.result is left unset.
data modify storage macroengine:text s set from storage macroengine:input string
data modify storage macroengine:text needle set from storage macroengine:input find
data modify storage macroengine:text rep set from storage macroengine:input replace
data remove storage macroengine:text n
data modify storage macroengine:text n set from storage macroengine:input n
function macroengine:core/internal/text/replace
data remove storage macroengine:output string.result
execute unless data storage macroengine:text err run data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
