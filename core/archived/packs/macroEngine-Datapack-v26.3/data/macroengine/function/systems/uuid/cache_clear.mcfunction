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
execute if data storage macroengine:engine modules{uuid:0b} run return 0
data modify storage macroengine:engine uuid_cache set value {}
