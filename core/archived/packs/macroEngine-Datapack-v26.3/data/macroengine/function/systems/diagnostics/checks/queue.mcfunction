# macroengine:systems/diagnostics/checks/queue
# Internal: called by systems/diagnostics/collect. Reads the work queue size and the applied cap.
# Codes: queue.over_cap  queue.not_draining:sys_queue_off

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0

execute store result score #macroengine.dg_q macroengine.tmp run data get storage macroengine:engine work_queue
execute store result storage macroengine:output diagnostics.queue.size int 1 run scoreboard players get #macroengine.dg_q macroengine.tmp
execute store result storage macroengine:output diagnostics.queue.cap int 1 run scoreboard players get #queue_cap macroengine.tick

execute if score #queue_cap macroengine.tick matches 1.. if score #macroengine.dg_q macroengine.tmp > #queue_cap macroengine.tick run data modify storage macroengine:output diagnostics.issues append value "queue.over_cap"
execute if score #sys_queue macroengine.tick_flags matches 0 if score #macroengine.dg_q macroengine.tmp matches 1.. run data modify storage macroengine:output diagnostics.issues append value "queue.not_draining:sys_queue_off"
