# Processes exactly one action: queued request first, otherwise one direct api request.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute if score #debug rtw.config matches 1.. if score #silent rtw.config matches 0 run tellraw @a[tag=rtwrapper.debug] [{"text":"[RTWrapper] run_next","color":"gold"}]
function rtwrapper:core/wrappers/handler/main
