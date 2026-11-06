# RTWrapper generated 3-parameter macro variant for /schedule.
# Parameters: action, function_id, time
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$schedule $(action) $(function_id) $(time)
