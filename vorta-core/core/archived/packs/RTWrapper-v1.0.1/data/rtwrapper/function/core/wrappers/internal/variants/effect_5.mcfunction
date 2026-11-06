# RTWrapper generated 5-parameter macro variant for /effect.
# Parameters: action, targets, effect, duration, amplifier
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$effect $(action) $(targets) $(effect) $(duration) $(amplifier)
