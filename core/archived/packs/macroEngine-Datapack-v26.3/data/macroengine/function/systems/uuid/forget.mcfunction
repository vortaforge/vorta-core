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
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
function macroengine:core/internal/systems/uuid/forget_key with storage macroengine:input
