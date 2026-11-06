execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine queue[0].func if data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue_run_func_as with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].func unless data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue_run_func with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].cmd if data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue_run_cmd_as with storage macroengine:engine queue[0]
execute if data storage macroengine:engine queue[0].cmd unless data storage macroengine:engine queue[0].player run function macroengine:core/internal/core/lib/queue_run_cmd with storage macroengine:engine queue[0]
data remove storage macroengine:engine queue[0]
