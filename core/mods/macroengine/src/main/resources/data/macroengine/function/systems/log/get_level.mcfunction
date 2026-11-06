# macroengine:systems/log/get_level
# Usage: /function macroengine:systems/log/get_level
# Shows the current log level.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{log:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Log level: ","color":"gray"},{"score":{"name":"#macroengine.log_level","objective":"macroengine.log_level"},"color":"white","bold":true},{"text":"  (0=off 1=error 2=warn 3=info 4=debug)","color":"#555555"}]
