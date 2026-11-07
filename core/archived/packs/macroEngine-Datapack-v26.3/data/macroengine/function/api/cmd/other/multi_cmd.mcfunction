# macroengine:api/cmd/other/multi_cmd [MACRO]
# Executes a list of commands in order.
# INPUT (macro args): $(commands) — list of command strings/objects
#

execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
$data modify storage macroengine:engine _mcmd_queue set value $(commands)
data modify storage macroengine:engine _mcmd_options set value {error_mode:"continue",profile:0b,spread:0}

execute at @s run function macroengine:api/cmd/other/multi_cmd/run
