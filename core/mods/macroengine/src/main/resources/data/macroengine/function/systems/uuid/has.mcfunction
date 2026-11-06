# ============================================================
# macroengine:systems/uuid/has
# Checks whether the specified key exists in the cache
#
# EXAMPLE:
# data modify storage macroengine:input key set value "my_key"
# execute if score $result macroengine.tmp matches 1 ...
# function macroengine:systems/uuid/has
#
# INPUT:
# macroengine:input key → name of the key to check
#
# OUTPUT:
# $uuid.has macroengine.tmp → 1 (found) or 0 (not found)
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
scoreboard players set $uuid.has macroengine.tmp 0
function macroengine:core/internal/systems/uuid/has_check with storage macroengine:input
