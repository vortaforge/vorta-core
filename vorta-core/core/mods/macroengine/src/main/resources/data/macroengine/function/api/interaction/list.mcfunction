execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{interaction:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"interaction/list","color":"aqua"}]
tellraw @s ["",{"text":" attack: ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"interaction_binds.attack","color":"white","interpret":false}]
tellraw @s ["",{"text":" use: ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"interaction_binds.use","color":"white","interpret":false}]
