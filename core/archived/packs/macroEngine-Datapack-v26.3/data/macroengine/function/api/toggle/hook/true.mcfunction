# macroengine:api/toggle/hook/true — Enable the hook module
# Called by the module toggle menu when State = true.
# Caller: macroengine.admin tag required (enforced by the admin-tag guard in show.mcfunction)

execute unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_hook set value 1b
function macroengine:core/config/apply


tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"hook","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"enabled","color":"green"}]