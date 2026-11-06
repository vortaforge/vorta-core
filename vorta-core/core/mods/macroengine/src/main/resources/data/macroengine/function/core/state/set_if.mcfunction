# ======================================================================================
# macroengine:core/state/set_if
# Compare-and-set for a player state: change the state to <to> only while it is still <from>.
# A safe building block for state machines (idle -> casting -> cooldown) because two
# systems cannot both win the same transition.
#
# INPUT  (storage macroengine:input state):  player, from, to
# OUTPUT macroengine:output result: 1b = changed, 0b = not changed (or invalid input)
# RETURN 1 when changed, 0 otherwise.
#
# Reads/writes the same storage as core/state/set|get|is. All three values are checked with
# systems/validate/safe_name before they reach a macro line.
#
# Usage:
#   data modify storage macroengine:input state set value {player:"Steve",from:"idle",to:"casting"}
#   execute if function macroengine:core/state/set_if run say started
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output result set value 0b
execute unless data storage macroengine:input state.player run return 0
execute unless data storage macroengine:input state.from run return 0
execute unless data storage macroengine:input state.to run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input state.player
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input state.from
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input state.to
execute unless function macroengine:systems/validate/safe_name run return 0

return run function macroengine:core/internal/ext/state/set_if with storage macroengine:input state
