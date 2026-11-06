# ======================================================================================
# macroengine:api/perm/count
# Counts the permissions stored for one player (api/perm/grant entries).
# Admin status (tag macroengine.admin) is not a stored permission and is not counted.
#
# INPUT  (storage macroengine:input perm):  player   the player name
# OUTPUT macroengine:output result (int)
# RETURN the count, 0 when the player has none or the name is invalid.
#
# The name is checked with systems/validate/safe_name while it is still data, before it
# reaches a macro line (same pattern as api/perm/require).
#
# Usage:
#   data modify storage macroengine:input perm.player set value "Steve"
#   function macroengine:api/perm/count
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{perm:0b} run return 0
data modify storage macroengine:output result set value 0
execute unless data storage macroengine:input perm.player run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input perm.player
execute unless function macroengine:systems/validate/safe_name run return 0

function macroengine:core/internal/ext/api/perm_count with storage macroengine:input perm
return run data get storage macroengine:output result
