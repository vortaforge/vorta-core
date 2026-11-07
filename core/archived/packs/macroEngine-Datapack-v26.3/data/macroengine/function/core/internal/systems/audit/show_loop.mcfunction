# macroengine:core/internal/systems/audit/show_loop  [INTERNAL]
# Prints entry #au_i, then recurses until #au_i reaches #au_n. Depth is at most 10.
execute store result storage macroengine:audit idx.i int 1 run scoreboard players get #macroengine.au_i macroengine.tmp
function macroengine:core/internal/systems/audit/show_one with storage macroengine:audit idx
scoreboard players add #macroengine.au_i macroengine.tmp 1
execute if score #macroengine.au_i macroengine.tmp < #macroengine.au_n macroengine.tmp run function macroengine:core/internal/systems/audit/show_loop
