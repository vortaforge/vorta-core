# macroengine:core/state/get_score
# Prints the calling player's current state score.
# Usage: /function macroengine:core/state/get_score
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s ["",{"text":"[State] ","color":"aqua"},{"text":"current: ","color":"gray"},{"score":{"name":"@s","objective":"macroengine.state"},"color":"white","bold":true}]
