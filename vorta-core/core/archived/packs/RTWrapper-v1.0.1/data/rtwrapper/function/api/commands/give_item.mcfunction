# Direct API convenience wrapper. Put named params in storage rtwrapper:api params.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
function rtwrapper:core/wrappers/internal/give_item with storage rtwrapper:api params
