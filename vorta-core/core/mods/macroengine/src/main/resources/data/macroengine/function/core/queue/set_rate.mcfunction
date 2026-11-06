# macroengine:core/queue/set_rate
# Sets how many work_queue items are processed per tick.
# Default: 1. Raise for faster throughput; lower to reduce tick cost.
# A value of 0 pauses processing.
#
# Input  (macroengine:input queue):
#   rate — integer ≥ 0
#
# Usage:
#   data modify storage macroengine:input queue.rate set value 4
#   function macroengine:core/queue/set_rate with storage macroengine:input queue

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine work_queue_rate set value $(rate)
