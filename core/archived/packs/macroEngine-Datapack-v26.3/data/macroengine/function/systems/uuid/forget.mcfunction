# ============================================================
# macroengine:systems/uuid/forget
# Deletes a UUID entry from the cache
#
# USAGE:
# data modify storage macroengine:input key set value "benim_anahtarim"
# function macroengine:systems/uuid/forget
#
# INPUT:
# macroengine:input key → name of the key to delete
# ============================================================
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/forget_key with storage macroengine:input
