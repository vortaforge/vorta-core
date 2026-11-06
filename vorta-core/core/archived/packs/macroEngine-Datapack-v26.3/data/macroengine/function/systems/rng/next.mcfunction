# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/next
# Advances the generator and writes the raw new state to
# macroengine:output result. Unbounded — use systems/rng/int when a
# value inside a range is wanted.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
function macroengine:core/internal/systems/rng/_core
execute store result storage macroengine:output result int 1 run scoreboard players get $rng_state macroengine.tmp
