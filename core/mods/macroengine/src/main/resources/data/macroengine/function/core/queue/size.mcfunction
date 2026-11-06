# macroengine:core/queue/size
# Writes the current work_queue item count to macroengine:output queue.size.
# No macro input required.
#
# Output (macroengine:output queue):
#   size — int  number of pending items
#
# Usage:
#   function macroengine:core/queue/size
#   data get storage macroengine:output queue.size

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage macroengine:output queue.size int 1 run data get storage macroengine:engine work_queue