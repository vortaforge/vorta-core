# macroengine:core/internal/api/perm/require_invalid  [INTERNAL]
# The permission name failed validation. The raw value is NOT echoed or stored.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
playsound macroengine:perm.denied master @s ~ ~ ~ 1 1
tellraw @s ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"✘ ","color":"red"},{"translate":"macroengine.msg.require_invalid","color":"red"}]
data modify storage macroengine:audit in set value {action:"perm.require.invalid",detail:"rejected permission name"}
function macroengine:systems/audit/record
