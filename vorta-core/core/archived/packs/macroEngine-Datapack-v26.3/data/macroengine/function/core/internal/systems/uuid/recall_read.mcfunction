# ============================================================
# macroengine:systems/uuid/internal/recall_read [MACRO FUNCTION]
# Reads UUID string from the cache
#
# Call: function macroengine:core/internal/systems/uuid/recall_read with storage macroengine:input
# $(key) = key name
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:output uuid set from storage macroengine:engine uuid_cache.$(key).str
