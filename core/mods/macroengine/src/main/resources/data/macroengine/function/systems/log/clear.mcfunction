# macroengine:systems/log/clear
# Usage: /function macroengine:systems/log/clear
# Clears the log buffer.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{log:0b} run return 0
execute unless entity @s[tag=macroengine.admin] run return 0
data remove storage macroengine:engine log_display
scoreboard players set #macroengine.log_count macroengine.tmp 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"Log buffer cleared.","color":"gray"}]
