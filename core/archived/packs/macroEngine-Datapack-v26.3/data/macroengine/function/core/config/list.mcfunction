# macroengine:core/config/list
# Prints the runtime config to @s. The values are read from storage by an NBT component.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"config ","color":"aqua"},{"storage":"macroengine:engine","nbt":"config","interpret":false,"color":"green","plain":true}]
