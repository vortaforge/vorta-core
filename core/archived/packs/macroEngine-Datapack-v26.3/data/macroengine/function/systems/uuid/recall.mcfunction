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
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/recall_read with storage macroengine:input
