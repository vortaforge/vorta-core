# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/vec/sub
# Subtracts vector B from vector A. (A - B)
#
# INPUT: ax, ay, az, bx, by, bz
# OUTPUT: macroengine:output {x, y, z}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
function macroengine:core/internal/systems/math/vec/sub_exec with storage macroengine:input {}
