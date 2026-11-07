# macroengine:api/perm/group/list
# Prints every group and its permission list to @s (storage, not per-player
# tags - use api/perm/list {player:...} for one player's direct grants).

execute if data storage macroengine:engine modules{perm:0b} run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Permission groups ━━━━━━━━━━━━━━","color":"aqua"}]
execute if data storage macroengine:engine groups run tellraw @s ["",{"text":" ","color":"#555555"},{"plain":true,"storage":"macroengine:engine","nbt":"groups","interpret":false,"color":"yellow"}]
execute unless data storage macroengine:engine groups run tellraw @s ["",{"text":" ","color":"#555555"},{"text":"(no groups)","color":"gray","italic":true}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
