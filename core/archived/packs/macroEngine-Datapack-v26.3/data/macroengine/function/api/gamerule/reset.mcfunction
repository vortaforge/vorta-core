# macroengine:api/gamerule/reset [MACRO]
# Removes a custom gamerule from engine storage entirely.
# Does NOT touch vanilla /gamerule — this is for macroengine-tracked rules only.
#
# INPUT (macro args via `with storage macroengine:input {}`):
#   $(rule) — rule name string
#
# EXAMPLE:
#   data modify storage macroengine:input rule set value "pvp_enabled"
#   function macroengine:api/gamerule/reset with storage macroengine:input {}


# Normalize key (spaces -> underscores, lowercase). Leaves _gamerule_norm unset when
# the name cannot be normalized safely (contains a quote or a backslash).
execute if data storage macroengine:engine modules{gamerule:0b} run return 0
data remove storage macroengine:input _gamerule_norm
function macroengine:core/internal/api/gamerule/normalize

function macroengine:core/internal/api/gamerule/remove with storage macroengine:input {}

data remove storage macroengine:input _gamerule_norm