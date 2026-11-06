execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage rtwrapper:api batch[0] run return 0

scoreboard players operation #batch_id rtw.status = #processed rtw.status

function rtwrapper:api/enqueue_batch_step

data remove storage rtwrapper:api batch
