# macroengine:api/color/palette_delete [MACRO]
# Removes a color alias from the runtime palette.
#
# Input (macro args):
#   key — alias name to remove
#
# Output → none
#
# Usage:
#   function macroengine:api/color/palette_delete {key:"brand"}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{color:0b} run return 0
$data remove storage macroengine:engine color.palette.$(key)