# Enqueue rtwrapper:api request for later processing.
# Accepts either {cmd:"..."} or {type:"..."}; proc normalizes type -> cmd.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage rtwrapper:api request.cmd run data modify storage rtwrapper:runtime queue append from storage rtwrapper:api request
execute if data storage rtwrapper:api request.cmd run data remove storage rtwrapper:api request
execute unless data storage rtwrapper:api request.cmd if data storage rtwrapper:api request.type run data modify storage rtwrapper:runtime queue append from storage rtwrapper:api request
execute if data storage rtwrapper:api request.type run data remove storage rtwrapper:api request
