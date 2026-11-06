# ======================================================================================
# macroengine:player/toggle_var
# Flips a boolean player variable: 0 / missing -> 1b, anything else -> 0b.
#
# INPUT  (storage macroengine:input pvar):  player, key
# OUTPUT macroengine:output result: the new value (1b / 0b)
# RETURN 1 when the new value is 1b, 0 when it is 0b or the input is invalid.
#
# Same storage as player/get_var|set_var. player and key are checked with
# systems/validate/safe_name before any macro line.
#
# Usage:
#   data modify storage macroengine:input pvar set value {player:"Steve",key:"pvp"}
#   function macroengine:player/toggle_var
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input pvar.player run return 0
execute unless data storage macroengine:input pvar.key run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input pvar.player
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input pvar.key
execute unless function macroengine:systems/validate/safe_name run return 0

return run function macroengine:core/internal/ext/player/toggle_var with storage macroengine:input pvar
