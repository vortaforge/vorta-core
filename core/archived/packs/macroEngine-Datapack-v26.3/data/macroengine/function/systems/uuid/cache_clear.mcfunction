# ============================================================
# macroengine:systems/uuid/cache_clear
# Clears all cache (all entries saved with uuid/store)
#
# USAGE:
# function macroengine:systems/uuid/cache_clear
#
# Warning: This operation is irreversible. All stored UUIDs are deleted.
# Typically used when resetting the world or when a player leaves.
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
data modify storage macroengine:engine uuid_cache set value {}
