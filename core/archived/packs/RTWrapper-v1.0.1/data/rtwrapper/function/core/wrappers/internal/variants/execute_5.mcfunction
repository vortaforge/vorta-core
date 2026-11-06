# RTWrapper generated 5-parameter macro variant for /execute.
# Parameters: step01, step02, step03, step04, step05
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$execute $(step01) $(step02) $(step03) $(step04) $(step05)
