# Helper for api/enqueue_batch. Consumes rtwrapper:api batch[0] the same way
# handler/dequeue consumes runtime queue[0], tags it with the shared batch_id, appends it
# to the normal runtime queue, and repeats until the batch array is empty.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage rtwrapper:api batch[0].batch_id int 1 run scoreboard players get #batch_id rtw.status
data modify storage rtwrapper:runtime queue append from storage rtwrapper:api batch[0]
data remove storage rtwrapper:api batch[0]
execute if data storage rtwrapper:api batch[0] run function rtwrapper:api/enqueue_batch_step
