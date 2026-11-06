# macroengine:core/internal/api/store/_tok_g [INTERNAL]  token %g:name%
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:store tmp.rest set string storage macroengine:store tmp.nm 2
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store tmp.rest
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:store tmp.k set value {}
data modify storage macroengine:store tmp.k.name set from storage macroengine:store tmp.rest
function macroengine:core/internal/api/store/_tok_g_get with storage macroengine:store tmp.k
execute if data storage macroengine:store tmp.raw run function macroengine:core/internal/api/store/_accept
