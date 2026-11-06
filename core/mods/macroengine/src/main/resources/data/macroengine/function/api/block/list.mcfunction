# macroengine:api/block/list
# Prints the registered custom blocks to @s.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{block:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"block/list","color":"aqua"}]
tellraw @s ["",{"text":" blocks: ","color":"#555555"},{"plain":true,"storage":"macroengine:engine","nbt":"block_registry","color":"white","interpret":false}]
