# macroengine:api/block/list
# Prints the registered custom blocks to @s.
execute if data storage macroengine:engine modules{block:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"block/list","color":"aqua"}]
tellraw @s ["",{"text":" blocks: ","color":"#555555"},{"plain":true,"storage":"macroengine:engine","nbt":"block_registry","color":"white","interpret":false}]
