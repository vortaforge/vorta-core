# macroengine:api/color/resolve [MACRO]
# Looks up a named palette entry or returns the value as-is if not found.
# Use this to map short alias keys (e.g. "brand", "danger", "info") to hex.
#
# The palette is stored in macroengine:engine color.palette as a compound:
#   {brand:"#00AAAA", danger:"red", info:"aqua", ...}
# Populate via macroengine:api/color/palette_set.
#
# Input (macro args):
#   color — alias key or direct color value
#
# Output → macroengine:output result
#   The resolved color string (palette value if key found; input value otherwise).
#
# Usage:
#   function macroengine:api/color/resolve {color:"brand"}
#   # → macroengine:output result = "#00AAAA"  (if palette has brand→#00AAAA)
#
#   function macroengine:api/color/resolve {color:"red"}
#   # → macroengine:output result = "red"  (not in palette, returned as-is)

# Default: return input value
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{color:0b} run return 0
$data modify storage macroengine:output result set value "$(color)"

# Override if palette has this key — write color key into temp so resolve_exec can access it
$data modify storage macroengine:engine _color_resolve_tmp set value {color:"$(color)"}
execute if data storage macroengine:engine color.palette run function macroengine:core/internal/systems/color/resolve_exec with storage macroengine:engine _color_resolve_tmp
data remove storage macroengine:engine _color_resolve_tmp