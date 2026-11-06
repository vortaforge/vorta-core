# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/vec/normalize
# Scales vector to unit length (×1000 fixed-point).
# Length computed via math/distance3d (floor(√(x²+y²+z²))).
# Results are ×1000 — divide by 1000 before using as direction vector.
#
# INPUT: x, y, z
# OUTPUT: macroengine:output {x, y, z, length}
# If length=0, zero vector — returns x,y,z=0.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
function macroengine:core/internal/systems/math/vec/normalize_exec with storage macroengine:input {}
