# macroengine:core/internal/load/force
# Force reload: applies immediately (no confirmation gate). Discards live
# engine state (global.loaded and everything load/all's "unless data"
# guards would otherwise preserve).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/load/force_apply
