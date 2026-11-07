# macroengine:api/color/palette_get [MACRO]
# Reads a color alias from the runtime palette.
#
# Input (macro args):
#   key — alias name (e.g. "brand")
#
# Output → macroengine:output result
#   The stored color value, or absent if key not found.
#
# Usage:
#   function macroengine:api/color/palette_get {key:"brand"}
#   data get storage macroengine:output result


execute if data storage macroengine:engine modules{color:0b} run return 0
data modify storage macroengine:output result set value ""
$execute if data storage macroengine:engine color.palette.$(key) run data modify storage macroengine:output result set from storage macroengine:engine color.palette.$(key)