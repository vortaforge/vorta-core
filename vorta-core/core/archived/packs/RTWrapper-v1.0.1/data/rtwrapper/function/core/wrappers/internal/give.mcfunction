# RTWrapper generated named-parameter dispatcher for /give.
# Provide contiguous parameters in this order:
# target, item, count
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #pc rtw.status 0
execute if data storage rtwrapper:runtime current.params.target run scoreboard players set #pc rtw.status 1
execute if data storage rtwrapper:runtime current.params.item run scoreboard players set #pc rtw.status 2
execute if data storage rtwrapper:runtime current.params.count run scoreboard players set #pc rtw.status 3
execute if score #pc rtw.status matches 0 run function rtwrapper:core/wrappers/internal/variants/give_0
execute if score #pc rtw.status matches 1 run function rtwrapper:core/wrappers/internal/variants/give_1 with storage rtwrapper:runtime current.params
execute if score #pc rtw.status matches 2 run function rtwrapper:core/wrappers/internal/variants/give_2 with storage rtwrapper:runtime current.params
execute if score #pc rtw.status matches 3 run function rtwrapper:core/wrappers/internal/variants/give_3 with storage rtwrapper:runtime current.params
