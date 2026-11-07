# ME - Universal World Clock Controller
# Usage: /function macroengine:api/cmd/time_of {clock:"macroengine:test", action:"set", value:"12000"}
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.time_of"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
$time of $(clock) $(action) $(value)