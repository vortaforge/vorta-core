# Macro: called with storage rtwrapper:api trigger (fields: objective, action).
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage rtwrapper:triggers registry[{objective:"$(objective)"}].action set from storage rtwrapper:api trigger.action
