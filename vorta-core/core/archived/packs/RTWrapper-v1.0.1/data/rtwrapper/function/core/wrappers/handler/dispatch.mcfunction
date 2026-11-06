# Debug, accounting, then dynamic macro dispatch into core/wrappers/internal/<cmd>.mcfunction.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add #processed rtw.status 1
execute if score #debug rtw.config matches 1.. if score #silent rtw.config matches 0 run function rtwrapper:core/wrappers/handler/debug_dispatch with storage rtwrapper:runtime current
execute store success score #dispatch_ok rtw.status run function rtwrapper:core/wrappers/handler/exec with storage rtwrapper:runtime current
execute if score #dispatch_ok rtw.status matches 0 run function rtwrapper:core/wrappers/handler/error_bad_cmd with storage rtwrapper:runtime current
