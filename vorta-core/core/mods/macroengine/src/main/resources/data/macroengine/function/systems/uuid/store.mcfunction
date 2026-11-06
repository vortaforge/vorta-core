# ============================================================
# macroengine:systems/uuid/store
# Caches @s entity's UUID as both string and int array
#
# USAGE:
# data modify storage macroengine:input key set value "benim_anahtarim"
# execute as <entity> run function macroengine:systems/uuid/store
#
# INPUT:
# macroengine:input key → storage key name (e.g. "spawn_point_owner")
#
# OUTPUT (macroengine:engine uuid_cache.<key>):
# .str → UUID hex string
# .arr → UUID int array [I; a, b, c, d]
#
# Not available in GU — an advanced AME-specific function.
# ============================================================

# Build UUID string → macroengine:output uuid
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:systems/uuid/from_entity

# Also save array form (from_entity already filled _work)
data modify storage macroengine:uuid _store_arr set from storage macroengine:uuid _work

# Write both to cache (get key name via macro)
data modify storage macroengine:uuid _store_args set value {}
data modify storage macroengine:uuid _store_args.key set from storage macroengine:input key
data modify storage macroengine:uuid _store_args.value set from storage macroengine:output uuid
function macroengine:core/internal/systems/uuid/store_write with storage macroengine:uuid _store_args
data remove storage macroengine:uuid _store_args
