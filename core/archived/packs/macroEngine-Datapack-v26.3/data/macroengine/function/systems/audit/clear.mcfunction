# macroengine:systems/audit/clear
# Empties the audit trail. ADMIN ONLY. Leaves one tombstone entry so the clear is itself
# recorded (who cleared it, and when).
#
# Usage:  function macroengine:systems/audit/clear

execute if data storage macroengine:engine modules{audit:0b} run return 0
execute if entity @s unless entity @s[tag=macroengine.admin] run playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
execute if entity @s unless entity @s[tag=macroengine.admin] run return run tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.permission_denied","color":"red"}]

data remove storage macroengine:audit entries
data modify storage macroengine:audit in set value {action:"audit.clear",detail:"entries cleared"}
function macroengine:systems/audit/record
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"translate":"macroengine.msg.audit_cleared","color":"green"}]
