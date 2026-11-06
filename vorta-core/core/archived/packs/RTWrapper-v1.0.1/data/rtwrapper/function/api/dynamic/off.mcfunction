execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #dynamic rtw.config 0
data modify storage rtwrapper:runtime config.dynamic set value 0b
tellraw @s [{"text":"[RTWrapper] dynamic command dispatch OFF (default)","color":"gold"}]
