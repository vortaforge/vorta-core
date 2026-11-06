# ============================================================
# macroengine:systems/uuid/internal/forget_key [MACRO FUNCTION]
# Deletes the specified key from uuid_cache
#
# Call: function macroengine:core/internal/systems/uuid/forget_key with storage macroengine:input
# $(key) = name of the key to delete
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine uuid_cache.$(key)
