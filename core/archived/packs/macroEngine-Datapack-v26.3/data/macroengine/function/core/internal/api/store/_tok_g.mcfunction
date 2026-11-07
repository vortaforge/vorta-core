# macroengine:core/internal/api/store/_tok_g [INTERNAL]  token %g:name%
data modify storage macroengine:store tmp.rest set string storage macroengine:store tmp.nm 2
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store tmp.rest
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:store tmp.k set value {}
data modify storage macroengine:store tmp.k.name set from storage macroengine:store tmp.rest
function macroengine:core/internal/api/store/_tok_g_get with storage macroengine:store tmp.k
execute if data storage macroengine:store tmp.raw run function macroengine:core/internal/api/store/_accept
