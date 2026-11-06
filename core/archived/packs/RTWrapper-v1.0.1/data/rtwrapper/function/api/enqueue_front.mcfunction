# Priority enqueue: same request shapes as api/enqueue, but inserts at the FRONT
# of the queue (index 0) instead of appending. Use when a dependent pack needs its
# action to run before whatever is already queued (e.g. an urgent correction),
# without disturbing the relative order of the rest of the queue.
# Accepts either {cmd:"..."} or {type:"..."}; proc normalizes type -> cmd, same as enqueue.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage rtwrapper:api request.cmd run data modify storage rtwrapper:runtime queue insert 0 from storage rtwrapper:api request
execute if data storage rtwrapper:api request.cmd run data remove storage rtwrapper:api request
execute unless data storage rtwrapper:api request.cmd if data storage rtwrapper:api request.type run data modify storage rtwrapper:runtime queue insert 0 from storage rtwrapper:api request
execute if data storage rtwrapper:api request.type run data remove storage rtwrapper:api request
