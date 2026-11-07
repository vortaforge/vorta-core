# macroengine:api/toggle/perm/false — Disable the perm module: permission checks pass for everybody (cmd_gate stays strict)

# Who may flip it: a server/console executor (no entity) or a player with the macroengine.admin tag.
execute if entity @s unless entity @s[tag=macroengine.admin] run playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.module_perm set value 0b
function macroengine:core/config/apply
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"perm","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"disabled","color":"red"}]
