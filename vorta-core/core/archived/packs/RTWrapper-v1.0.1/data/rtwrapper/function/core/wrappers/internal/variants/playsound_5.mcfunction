# RTWrapper generated 5-parameter macro variant for /playsound.
# Parameters: sound, source, targets, pos, volume
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$playsound $(sound) $(source) $(targets) $(pos) $(volume)
