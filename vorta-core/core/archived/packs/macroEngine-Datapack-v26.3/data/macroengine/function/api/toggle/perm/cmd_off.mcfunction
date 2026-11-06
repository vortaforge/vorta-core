# macroengine:api/toggle/perm/cmd_off
# Per-command permissions OFF (default): api/cmd/* wrappers are not permission-checked.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# Who may flip it: a server/console executor (no entity) or a player with the macroengine.admin tag.
execute if entity @s unless entity @s[tag=macroengine.admin] run playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine config.perm_cmd set value 0b
function macroengine:core/config/apply
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"per-command permissions","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"off","color":"red"}]
