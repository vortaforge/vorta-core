execute if data storage macroengine:engine modules{perm:0b} run return 0
$tellraw @s["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Perms: ","color":"aqua"},{"text":"$(player)","color":"white","bold":true},{"text":" ━━━━━━━━━━━━━━","color":"#555555"}]
$execute if data storage macroengine:engine permissions.$(player) run tellraw @s ["",{"text":" ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"permissions.$(player)","interpret":false,"color":"yellow"}]
$execute unless data storage macroengine:engine permissions.$(player) run tellraw @s ["",{"text":" ","color":"#555555"},{"text":"(no permissions)","color":"gray","italic":true}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
