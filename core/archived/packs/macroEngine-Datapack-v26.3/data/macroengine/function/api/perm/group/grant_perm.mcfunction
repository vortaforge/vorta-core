# macroengine:api/perm/group/grant_perm [MACRO]  INPUT: $(group) $(perm)
# Adds one permission name to an existing group. Players already in the
# group do not gain it until the group is assigned again - assignment is
# the moment membership is materialised into perm.<name> tags.
# Admin-only, like api/perm/grant; both names must pass safe_name.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{perm:0b} run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0
$data modify storage macroengine:validate in.value set value "$(group)"
execute unless function macroengine:systems/validate/safe_name run return 0
$data modify storage macroengine:validate in.value set value "$(perm)"
execute unless function macroengine:systems/validate/safe_name run return 0
$execute unless data storage macroengine:engine groups.$(group) run return run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"text":"$(group)","color":"yellow"},{"text":" - no such group; create it first.","color":"red"}]
$data modify storage macroengine:engine groups.$(group) append value "$(perm)"
return 1
