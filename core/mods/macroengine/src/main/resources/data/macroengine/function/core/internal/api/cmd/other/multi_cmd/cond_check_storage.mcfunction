# macroengine:core/internal/api/cmd/other/multi_cmd/cond_check_storage
# Existence-only storage leaf, kept for backward compatibility:
#   condition.storage = "namespace:path"
#
# To compare a VALUE use the `data` leaf instead — it supports numeric
# ranges and also fails closed when the path is missing.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_storage_exec with storage macroengine:engine _mcmd_cond_eval
