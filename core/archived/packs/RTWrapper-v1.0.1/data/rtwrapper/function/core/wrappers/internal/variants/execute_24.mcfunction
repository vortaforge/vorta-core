# RTWrapper generated 24-parameter macro variant for /execute.
# Parameters: step01, step02, step03, step04, step05, step06, step07, step08, step09, step10, step11, step12, step13, step14, step15, step16, step17, step18, step19, step20, step21, step22, step23, step24
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$execute $(step01) $(step02) $(step03) $(step04) $(step05) $(step06) $(step07) $(step08) $(step09) $(step10) $(step11) $(step12) $(step13) $(step14) $(step15) $(step16) $(step17) $(step18) $(step19) $(step20) $(step21) $(step22) $(step23) $(step24)
