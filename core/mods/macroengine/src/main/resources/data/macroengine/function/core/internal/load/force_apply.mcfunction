# macroengine:core/internal/load/force_apply
# Actually performs the force re-init: drops the loaded flag and
# re-runs the full init pipeline, discarding any live engine state
# that macroengine:core/internal/load/all's "unless data" guards would otherwise preserve.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:engine global.loaded
function macroengine:core/internal/load/all
