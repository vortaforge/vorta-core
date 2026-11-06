# macroengine:api/color/palette_list
# Prints all registered palette entries to the calling player.
# Requires macroengine.admin tag.
#
# Usage:
#   function macroengine:api/color/palette_list

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{color:0b} run return 0
execute unless entity @s[tag=macroengine.admin] run return 0

tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━ Color Palette ","color":"aqua"},{"text":"━━━━━━━━━━━","color":"#555555"}]
execute if data storage macroengine:engine color.palette run tellraw @s ["",{"text":" ","color":"#555555"},{"plain":true ,"storage":"macroengine:engine","nbt":"color.palette","interpret":false,"color":"green"}]
execute unless data storage macroengine:engine color.palette run tellraw @s ["",{"text":" ","color":"#555555"},{"text":"(palette is empty)","color":"gray","italic":true}]
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━","color":"#555555"}]
