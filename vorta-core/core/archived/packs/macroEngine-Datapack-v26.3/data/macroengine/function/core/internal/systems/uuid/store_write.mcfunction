# ============================================================
# macroengine:systems/uuid/internal/store_write [MACRO FUNCTION]
# UUID'yi macroengine:engine uuid_cache'e yazar (hem string hem array)
#
# Call: function macroengine:core/internal/systems/uuid/store_write with storage macroengine:uuid _store_args
# $(key)   = key name (from macroengine:input key, already copied by uuid/store)
# $(value) = UUID hex string (macroengine:output uuid, written by from_entity)
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine uuid_cache.$(key).str set value "$(value)"
$data modify storage macroengine:engine uuid_cache.$(key).arr set from storage macroengine:uuid _store_arr
