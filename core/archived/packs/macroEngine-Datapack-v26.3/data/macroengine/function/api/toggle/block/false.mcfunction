# macroengine:api/toggle/block/false — Disable the block module

execute unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_block set value 0b
function macroengine:core/config/apply

tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"block","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"disabled","color":"red"}]
