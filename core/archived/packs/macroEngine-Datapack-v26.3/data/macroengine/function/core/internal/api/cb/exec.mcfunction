# macroengine:api/cb/internal/exec
# Macro: called via "function ... with storage macroengine:input cb"
# Expected keys: cmd (string), x (int), y (int), z (int)
# The command is copied from storage (macroengine:input cb.cmd), not pasted
# into the macro line, so it may contain double quotes, e.g. say "hi".
#
# Side-effects:
#   • Writes macroengine:engine _cb_last {x,y,z} for the cleanup step.
#   • Schedules macroengine:api/cb/internal/reset 2t later.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:cmd_gate in.cmd set from storage macroengine:input cb.cmd
execute unless function macroengine:systems/cmd_gate/check run return 0
$data modify storage macroengine:engine _cb_last set value {x:$(x),y:$(y),z:$(z)}
$forceload add $(x) $(z)
$setblock $(x) $(y) $(z) minecraft:command_block{Command:"",auto:0b,TrackOutput:0b} replace
$data modify block $(x) $(y) $(z) Command set from storage macroengine:input cb.cmd
$data modify block $(x) $(y) $(z) auto set value 1b
schedule function macroengine:core/internal/api/cb/reset 2t replace
