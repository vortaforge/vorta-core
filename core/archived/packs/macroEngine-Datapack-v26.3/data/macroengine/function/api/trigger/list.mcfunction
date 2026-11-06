execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{trigger:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Trigger Binds ","color":"aqua"},{"text":"━━━━━━━━━━━━━","color":"#555555"}]
execute unless data storage macroengine:engine trigger_binds[0] run tellraw @s ["",{"text":" ","color":"#555555"},{"text":"(no binds registered)","color":"gray","italic":true}]
execute if data storage macroengine:engine trigger_binds[0] run tellraw @s ["",{"text":" ","color":"#555555"},{"nbt":"trigger_binds","plain":true ,"storage":"macroengine:engine","interpret":false,"color":"yellow"}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
