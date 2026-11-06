execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #auto_tick rtw.config 1
data modify storage rtwrapper:runtime config.auto_tick set value 1b
tellraw @s [{"text":"[RTWrapper] auto tick on","color":"gold"}]
