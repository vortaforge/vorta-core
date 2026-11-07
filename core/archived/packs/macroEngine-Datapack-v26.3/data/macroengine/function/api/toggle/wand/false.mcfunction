# macroengine:api/toggle/wand/false — Disable the wand module

execute unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_wand set value 0b
function macroengine:core/config/apply


tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"wand","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"disabled","color":"red"}]