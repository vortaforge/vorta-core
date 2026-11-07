# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/unregister
# Removes all wand binds belonging to a specific tag.
#
# INPUT:
#   $(tag) → tag to remove
# ─────────────────────────────────────────────────────────────────

execute unless data storage macroengine:engine wand_binds run return 0

data modify storage macroengine:engine _wand_unbinds set from storage macroengine:engine wand_binds
data modify storage macroengine:engine wand_binds set value []
$data modify storage macroengine:engine _wand_filter_tag set value "$(tag)"
function macroengine:core/internal/api/wand/unbind_filter
data remove storage macroengine:engine _wand_unbinds
data remove storage macroengine:engine _wand_filter_tag