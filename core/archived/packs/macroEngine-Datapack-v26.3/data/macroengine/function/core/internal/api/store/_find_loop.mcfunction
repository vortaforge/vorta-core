# macroengine:core/internal/api/store/_find_loop [INTERNAL]
# Tries the candidate languages in order. Every candidate is validated first, because
# stored language values are data a player or pack may have written.
execute unless data storage macroengine:store tmp.langs[0] run return 0
data modify storage macroengine:store tmp.k.lang set from storage macroengine:store tmp.langs[0]
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store tmp.k.lang
execute if function macroengine:systems/validate/safe_name run function macroengine:core/internal/api/store/_t_try with storage macroengine:store tmp.k
execute if data storage macroengine:store tmp.tpl run return 1
data remove storage macroengine:store tmp.langs[0]
function macroengine:core/internal/api/store/_find_loop
