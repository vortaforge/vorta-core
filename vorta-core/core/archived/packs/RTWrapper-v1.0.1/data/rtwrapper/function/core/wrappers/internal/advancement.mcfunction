# RTWrapper generated named-parameter dispatcher for /advancement.
# Provide contiguous parameters in this order:
# action, targets, range, advancement
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #pc rtw.status 0
execute if data storage rtwrapper:runtime current.params.action run scoreboard players set #pc rtw.status 1
execute if data storage rtwrapper:runtime current.params.targets run scoreboard players set #pc rtw.status 2
execute if data storage rtwrapper:runtime current.params.range run scoreboard players set #pc rtw.status 3
execute if data storage rtwrapper:runtime current.params.advancement run scoreboard players set #pc rtw.status 4
execute if score #pc rtw.status matches 0 run function rtwrapper:core/wrappers/internal/variants/advancement_0
execute if score #pc rtw.status matches 1 run function rtwrapper:core/wrappers/internal/variants/advancement_1 with storage rtwrapper:runtime current.params
execute if score #pc rtw.status matches 2 run function rtwrapper:core/wrappers/internal/variants/advancement_2 with storage rtwrapper:runtime current.params
execute if score #pc rtw.status matches 3 run function rtwrapper:core/wrappers/internal/variants/advancement_3 with storage rtwrapper:runtime current.params
execute if score #pc rtw.status matches 4 run function rtwrapper:core/wrappers/internal/variants/advancement_4 with storage rtwrapper:runtime current.params
