# macroengine:systems/audit/show
# Prints the latest 10 audit entries to the caller. ADMIN ONLY (tag macroengine.admin).
# A server/console executor (no entity) is treated as trusted, same as api/perm/grant.
#
# Usage:  function macroengine:systems/audit/show

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{audit:0b} run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
execute if entity @s unless entity @s[tag=macroengine.admin] run return run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]

execute store result score #macroengine.au_n macroengine.tmp run data get storage macroengine:audit entries
execute if score #macroengine.au_n macroengine.tmp matches ..0 run return run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.audit_empty","color":"gray"}]

tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.audit_header","color":"gray"}]

scoreboard players operation #macroengine.au_i macroengine.tmp = #macroengine.au_n macroengine.tmp
scoreboard players remove #macroengine.au_i macroengine.tmp 10
execute if score #macroengine.au_i macroengine.tmp matches ..-1 run scoreboard players set #macroengine.au_i macroengine.tmp 0
function macroengine:core/internal/systems/audit/show_loop
data remove storage macroengine:audit idx
