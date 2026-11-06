scoreboard players set #dynamic rtw.config 0
data modify storage rtwrapper:runtime config.dynamic set value 0b
tellraw @s [{"text":"[RTWrapper] dynamic command dispatch OFF (default)","color":"gold"}]
