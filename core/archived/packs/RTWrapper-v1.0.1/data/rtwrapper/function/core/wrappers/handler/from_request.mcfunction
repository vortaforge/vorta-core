execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
data modify storage rtwrapper:runtime current set from storage rtwrapper:api request
data remove storage rtwrapper:api request
function rtwrapper:core/wrappers/handler/proc
