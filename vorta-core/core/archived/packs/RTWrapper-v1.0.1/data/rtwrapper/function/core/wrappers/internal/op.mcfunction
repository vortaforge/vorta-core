# RTWrapper generated named-parameter dispatcher for /op.
# Provide contiguous parameters in this order:
# targets
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #pc rtw.status 0
execute if data storage rtwrapper:runtime current.params.targets run scoreboard players set #pc rtw.status 1
execute if score #pc rtw.status matches 0 run function rtwrapper:core/wrappers/internal/variants/op_0
execute if score #pc rtw.status matches 1 run function rtwrapper:core/wrappers/internal/variants/op_1 with storage rtwrapper:runtime current.params
