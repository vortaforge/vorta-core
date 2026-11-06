# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/vec/angle_between
# Returns the angle between two vectors in degrees.
# cos(θ) = dot(A,B) / (|A| × |B|) → θ = arccos(...)
# Uses ×1000 fixed-point cos table for arccos.
#
# INPUT: ax, ay, az, bx, by, bz
# OUTPUT: macroengine:output result (0–180, integer degrees)
# result=0 for zero vectors.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
function macroengine:core/internal/systems/math/vec/angle_exec with storage macroengine:input {}
