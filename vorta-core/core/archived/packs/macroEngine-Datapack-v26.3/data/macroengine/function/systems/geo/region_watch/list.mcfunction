# ─────────────────────────────────────────────────────────────────
# macroengine:systems/geo/region_watch/list
# Shows all registered regions to admin players.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{geo:0b} run return 0
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Region Watches ━━━━━━━━━━━━━━","color":"aqua"}]
execute if data storage macroengine:engine region_watches run tellraw @a[tag=macroengine.admin] ["",{"text":" ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"region_watches","interpret":false,"color":"yellow"}]
execute unless data storage macroengine:engine region_watches run tellraw @a[tag=macroengine.admin] ["",{"text":" (no regions registered)","color":"gray","italic":true}]
tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
