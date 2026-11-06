# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/unregister
# Removes all wand binds belonging to a specific tag.
#
# INPUT:
#   $(tag) → tag to remove
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine wand_binds run return 0

data modify storage macroengine:engine _wand_unbinds set from storage macroengine:engine wand_binds
data modify storage macroengine:engine wand_binds set value []
$data modify storage macroengine:engine _wand_filter_tag set value "$(tag)"
function macroengine:core/internal/api/wand/unbind_filter
data remove storage macroengine:engine _wand_unbinds
data remove storage macroengine:engine _wand_filter_tag