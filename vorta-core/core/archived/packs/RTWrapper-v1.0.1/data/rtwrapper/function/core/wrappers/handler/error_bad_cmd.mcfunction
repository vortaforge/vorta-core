# cmd was present but did not match any core/wrappers/internal/<cmd>.mcfunction dispatcher.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add #errors rtw.status 1
$execute if score #silent rtw.config matches 0 run tellraw @a[tag=rtwrapper.debug] [{"text":"[RTWrapper] unknown cmd: ","color":"red"},{"text":"$(cmd)","color":"white"}]
