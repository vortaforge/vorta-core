# macroengine:api/perm/group/create [MACRO]  INPUT: $(group)
# Creates an empty permission group. A group's permissions become effective
# through the existing perm.<name> tags when the group is assigned, so
# api/perm/require does not change. Admin-only, like api/perm/grant.
# The group name must pass systems/validate/safe_name before any macro
# line uses it (letters, digits, underscore, dot, hyphen).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{perm:0b} run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0
$data modify storage macroengine:validate in.value set value "$(group)"
execute unless function macroengine:systems/validate/safe_name run return 0
execute unless data storage macroengine:engine groups run data modify storage macroengine:engine groups set value {}
$execute unless data storage macroengine:engine groups.$(group) run data modify storage macroengine:engine groups.$(group) set value []
return 1
