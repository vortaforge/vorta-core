# ============================================================
# macroengine:systems/uuid/recall_array
# Retrieves UUID int array from the cache
#
# USAGE:
# data modify storage macroengine:input key set value "benim_anahtarim"
# function macroengine:systems/uuid/recall_array
#
# INPUT:
# macroengine:input key → key name used with uuid/store
#
# OUTPUT:
# macroengine:output uuid_array → UUID int array [I; a, b, c, d]
# (value unchanged if key not found)
#
# Use case: writing UUID to entity NBT (e.g. Owner field)
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/recall_arr_read with storage macroengine:input
