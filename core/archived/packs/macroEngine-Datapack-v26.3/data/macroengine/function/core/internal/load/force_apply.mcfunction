# macroengine:core/internal/load/force_apply
# Actually performs the force re-init: drops the loaded flag and
# re-runs the full init pipeline, discarding any live engine state
# that macroengine:core/internal/load/all's "unless data" guards would otherwise preserve.

data remove storage macroengine:engine global.loaded
function macroengine:core/internal/load/all
