# macroengine:core/queue/flush
# Processes ALL remaining work_queue items in a single tick.
# WARNING: large queues will cause a lag spike. Use only when you know
#          the queue is small (< ~50 items) or in a controlled context.
# No macro input required.
#
# Usage:
#   function macroengine:core/queue/flush

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine work_queue[0] run function macroengine:core/internal/core/queue/flush_loop