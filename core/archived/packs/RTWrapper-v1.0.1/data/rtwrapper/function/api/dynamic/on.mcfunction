scoreboard players set #dynamic rtw.config 1
data modify storage rtwrapper:runtime config.dynamic set value 1b
tellraw @s [{"text":"[RTWrapper] dynamic command dispatch ON - storage requests can now run wrapped commands","color":"gold"}]
