# ============================================================
# macroengine:systems/uuid/recall
# Retrieves UUID string from the cache
#
# USAGE:
# data modify storage macroengine:input key set value "benim_anahtarim"
# function macroengine:systems/uuid/recall
#
# INPUT:
# macroengine:input key → key name used with uuid/store
#
# OUTPUT:
# macroengine:output uuid → UUID hex string
# (value unchanged if key not found)
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/recall_read with storage macroengine:input
