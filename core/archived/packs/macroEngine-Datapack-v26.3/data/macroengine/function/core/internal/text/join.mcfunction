# macroengine:core/internal/text/join
# Concatenates the strings in macroengine:text pc into macroengine:text out.
# Every entry must already be free of double quotes and backslashes (see safe).
execute unless data storage macroengine:text pc[0] run data modify storage macroengine:text out set value ""
execute unless data storage macroengine:text pc[0] run return 1
execute unless data storage macroengine:text pc[1] run data modify storage macroengine:text out set from storage macroengine:text pc[0]
execute unless data storage macroengine:text pc[1] run return 1
function macroengine:core/internal/text/join_round
data modify storage macroengine:text out set from storage macroengine:text pc[0]
return 1
