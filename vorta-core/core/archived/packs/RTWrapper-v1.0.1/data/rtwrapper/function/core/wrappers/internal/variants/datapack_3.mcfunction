# RTWrapper generated 3-parameter macro variant for /datapack.
# Parameters: action, name, position
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$datapack $(action) $(name) $(position)
