# macroengine:api/perm/group/remove [MACRO]  INPUT: $(player) $(group)
# Removes an online player from a group: drops the group.<group> tag and
# the perm.<name> tag of every permission in the group. KNOWN LIMIT: if
# the same permission was also granted directly (api/perm/grant) or via a
# second group, the storage record from grant survives but the tag is
# removed here - re-grant it if the player must keep it. Admin-only.

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
data modify storage macroengine:engine _grp_tmp set value {mode:"remove",pending:[]}
$data modify storage macroengine:engine _grp_tmp.pending set from storage macroengine:engine groups.$(group)
$execute as @a if score @s macroengine.pid = $grp_pid macroengine.tmp run tag @s remove group.$(group)
function macroengine:core/internal/api/perm/group/_apply_loop
data remove storage macroengine:engine _grp_tmp
return 1
