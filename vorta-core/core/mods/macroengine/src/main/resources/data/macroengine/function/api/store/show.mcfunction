# macroengine:api/store/show
# Reads a global value (api/store/get) and prints it to @s with tellraw.
#
# INPUT  macroengine:store in.name (string)
# OUTPUT macroengine:store out.value (same as api/store/get); a chat line for @s
# RETURN 1 when the value exists and was shown, 0 when it is unset or in.name is missing or invalid.
#
# The value is read straight from storage by an NBT text component with "interpret": false,
# so strings are shown as written and numbers, lists and compounds as SNBT. Nothing is
# ever stored as a text component; the component only exists while the line is printed.
#
# Usage:
#   data modify storage macroengine:store in set value {name:"shop.price"}
#   function macroengine:api/store/show
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
execute store success score #st_show macroengine.tmp run function macroengine:api/store/get
execute if score #st_show macroengine.tmp matches 0 run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"store: value is not set, or in.name is missing or invalid","color":"yellow"}]
execute if score #st_show macroengine.tmp matches 0 run return 0
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"storage":"macroengine:store","nbt":"in.name","interpret":false,"color":"gray","plain":true},{"text":" = ","color":"dark_gray"},{"storage":"macroengine:store","nbt":"out.value","interpret":false,"color":"green","plain":true}]
return 1
