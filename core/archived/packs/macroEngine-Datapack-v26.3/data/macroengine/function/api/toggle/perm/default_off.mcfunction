# macroengine:api/toggle/perm/default_off
# Make "enforcement off" the DEFAULT. Takes effect when perm_enforce is created or reset (core/config/reset); it does not change the current state.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# Who may flip it: a server/console executor (no entity) or a player with the macroengine.admin tag.
execute if entity @s unless entity @s[tag=macroengine.admin] run playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0

data modify storage macroengine:engine perm_default set value 0b
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"perm default","color":"aqua"},{"text":" → ","color":"#555555"},{"text":"off","color":"red"}]
