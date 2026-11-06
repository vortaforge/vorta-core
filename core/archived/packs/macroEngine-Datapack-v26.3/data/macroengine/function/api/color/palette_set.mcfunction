# macroengine:api/color/palette_set [MACRO]
# Registers a named color alias in the runtime palette.
# Existing key is overwritten.
#
# Input (macro args):
#   key   — alias name (e.g. "brand", "danger", "success")
#   value — color value (named or hex, e.g. "#00AAAA", "red")
#
# Output → none
#
# Usage:
#   function macroengine:api/color/palette_set {key:"brand",value:"#00AAAA"}
#   function macroengine:api/color/palette_set {key:"danger",value:"red"}


execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{color:0b} run return 0
execute unless data storage macroengine:engine color.palette run data modify storage macroengine:engine color.palette set value {}
$data modify storage macroengine:engine color.palette.$(key) set value "$(value)"