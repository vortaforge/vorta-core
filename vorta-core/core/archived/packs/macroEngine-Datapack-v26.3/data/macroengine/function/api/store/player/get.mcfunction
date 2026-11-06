# macroengine:api/store/player/get
# per-player value of the executor (@s must be a player)
#
# INPUT  macroengine:store in.name
# OUTPUT macroengine:store out.value (removed first, so a stale value never survives a miss)
# RETURN 1 on success, 0 on invalid name / missing input / not a player.
#
# Plain strings in, plain strings out. Nothing here ever builds a text component.
# Names are checked with systems/validate/safe_name while they are still data in storage,
# before they reach a macro line (see api/perm/require for the same pattern).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store tmp
data remove storage macroengine:store out.value
execute unless function macroengine:core/internal/api/store/_name run return 0
execute unless function macroengine:core/internal/api/store/_uuid run return 0
return run function macroengine:core/internal/api/store/_p_get with storage macroengine:store tmp.k
