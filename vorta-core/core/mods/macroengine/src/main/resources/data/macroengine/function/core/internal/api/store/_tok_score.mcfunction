# macroengine:core/internal/api/store/_tok_score [INTERNAL]  token %score:objective%
# Writes the executor's score as a plain string into tmp.val. tmp.val stays unset when the
# objective name is invalid, the objective does not exist or the executor has no score.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:store tmp.rest set string storage macroengine:store tmp.nm 6
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:store tmp.rest
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:store tmp.k set value {}
data modify storage macroengine:store tmp.k.obj set from storage macroengine:store tmp.rest
data remove storage macroengine:store tmp.num
function macroengine:core/internal/api/store/_tok_score_build with storage macroengine:store tmp.k
execute if data storage macroengine:store tmp.num run data modify storage macroengine:store tmp.val set string storage macroengine:store tmp.num
data remove storage macroengine:store tmp.num
