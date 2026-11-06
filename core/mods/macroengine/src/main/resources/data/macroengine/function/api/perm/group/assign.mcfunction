# macroengine:api/perm/group/assign [MACRO]  INPUT: $(player) $(group)
# Puts an online player into a group: adds the group.<group> tag and one
# perm.<name> tag per permission in the group, which is exactly what
# api/perm/require already checks. Admin-only, like api/perm/grant; the
# player is resolved through player_pids the same way grant does it.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{perm:0b} run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]
execute if entity @s unless entity @s[tag=macroengine.admin] run return 0
$data modify storage macroengine:validate in.value set value "$(group)"
execute unless function macroengine:systems/validate/safe_name run return 0
$data modify storage macroengine:validate in.value set value "$(player)"
execute unless function macroengine:systems/validate/safe_name run return 0
scoreboard players set $grp_pid macroengine.tmp 0
$execute store result score $grp_pid macroengine.tmp run data get storage macroengine:engine player_pids.$(player)
execute if score $grp_pid macroengine.tmp matches 0 run return 0
$execute unless data storage macroengine:engine groups.$(group) run return 0
data modify storage macroengine:engine _grp_tmp set value {mode:"add",pending:[]}
$data modify storage macroengine:engine _grp_tmp.pending set from storage macroengine:engine groups.$(group)
$execute as @a if score @s macroengine.pid = $grp_pid macroengine.tmp run tag @s add group.$(group)
function macroengine:core/internal/api/perm/group/_apply_loop
data remove storage macroengine:engine _grp_tmp
return 1
