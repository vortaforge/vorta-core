# macroengine:core/queue/clear
# Discards all pending work_queue items immediately.
# No macro input required.
#
# Usage:
#   function macroengine:core/queue/clear

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine work_queue set value []