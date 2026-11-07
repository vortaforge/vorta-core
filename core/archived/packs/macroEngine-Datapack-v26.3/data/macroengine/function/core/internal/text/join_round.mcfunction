# macroengine:core/internal/text/join_round [INTERNAL] one reduction round, repeats until one entry is left
data modify storage macroengine:text nl set value []
function macroengine:core/internal/text/join_take
data modify storage macroengine:text pc set from storage macroengine:text nl
execute if data storage macroengine:text pc[1] run function macroengine:core/internal/text/join_round
