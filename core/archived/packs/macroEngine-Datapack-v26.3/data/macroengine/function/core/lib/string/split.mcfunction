# macroengine:core/lib/string/split
# Input:  macroengine:input string      — original string
#         macroengine:input separator   — split delimiter (default " ", ""=each char)
#         macroengine:input n           — max splits (0/unset=all, +n=first n, -n=last n)
#         macroengine:input keep_empty  — 1b to keep empty segments, omit/0b to strip
# Output: macroengine:output string.result — list of string segments
# Dep:    macroengine:core/internal/text (in-house)
# Note:   an unset separator defaults to " "
data modify storage macroengine:text s set from storage macroengine:input string
data modify storage macroengine:text sep set value " "
data modify storage macroengine:text sep set from storage macroengine:input separator
data remove storage macroengine:text n
data modify storage macroengine:text n set from storage macroengine:input n
data remove storage macroengine:text keep_empty
data modify storage macroengine:text keep_empty set from storage macroengine:input keep_empty
function macroengine:core/internal/text/split
data remove storage macroengine:output string.result
data modify storage macroengine:output string.result set from storage macroengine:text out
function macroengine:core/internal/text/reset
