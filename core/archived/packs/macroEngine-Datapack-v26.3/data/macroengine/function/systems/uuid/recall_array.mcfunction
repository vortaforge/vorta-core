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
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/recall_arr_read with storage macroengine:input
