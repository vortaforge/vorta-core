# macroengine:core/lib/string/find
# Input:  macroengine:input string  — haystack string
#         macroengine:input find    — substring to search
#         macroengine:input n       — instance count (0=all, +n=first n, -n=last n)
# Output: macroengine:output string.result — list of start indices, or [-1] if not found
# Dep:    macroengine:core/internal/text (in-house)
# Note:   no match (or an empty find string) gives [-1]
data modify storage macroengine:text s set from storage macroengine:input string
data modify storage macroengine:text needle set from storage macroengine:input find
data remove storage macroengine:text n
data modify storage macroengine:text n set from storage macroengine:input n
function macroengine:core/internal/text/find
data remove storage macroengine:output string.result
data modify storage macroengine:output string.result set from storage macroengine:text idx
execute unless data storage macroengine:text idx[0] run data modify storage macroengine:output string.result set value [-1]
function macroengine:core/internal/text/reset
