# macroengine:api/wand/list — Shows registered wand binds.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{wand:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Wand Binds ","color":"aqua"},{"text":"━━━━━━━━━━━━━━━","color":"#555555"}]
execute unless data storage macroengine:engine wand_binds[0] run tellraw @s ["",{"text":" ","color":"#555555"},{"text":"(no wand binds)","color":"gray","italic":true}]
execute if data storage macroengine:engine wand_binds[0] run tellraw @s ["",{"text":" ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"wand_binds","interpret":false,"color":"yellow"}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
