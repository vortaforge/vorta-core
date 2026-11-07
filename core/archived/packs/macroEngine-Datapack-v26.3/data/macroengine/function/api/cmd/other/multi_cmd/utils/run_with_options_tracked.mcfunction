execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.utils.run_with_options_tracked"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
data modify storage macroengine:output multiCommands.executed set value 0b

execute at @s store success storage macroengine:output multiCommands.executed byte 1 unless function macroengine:api/cmd/other/multi_cmd/advanced/run_with_options run return 0
