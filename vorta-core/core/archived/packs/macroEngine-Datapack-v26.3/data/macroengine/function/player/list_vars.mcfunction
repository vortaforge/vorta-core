execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Player: ","color":"aqua"},{"text":"$(player)","color":"white","bold":true},{"text":" ━━━━━━━━━━━━━━","color":"#555555"}]
$execute if data storage macroengine:engine players.$(player) run tellraw @a[tag=macroengine.admin] ["",{"text":" vars ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"players.$(player)","interpret":false,"color":"yellow"}]
$execute unless data storage macroengine:engine players.$(player) run tellraw @a[tag=macroengine.admin] ["",{"text":" vars ","color":"#555555"},{"text":"(no data)","color":"gray","italic":true}]
$execute if data storage macroengine:engine cooldowns.$(player) run tellraw @a[tag=macroengine.admin] ["",{"text":" cooldowns ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"cooldowns.$(player)","interpret":false,"color":"aqua"}]
$execute unless data storage macroengine:engine cooldowns.$(player) run tellraw @a[tag=macroengine.admin] ["",{"text":" cooldowns ","color":"#555555"},{"text":"(none active)","color":"gray","italic":true}]
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
