# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/state
# Copies the current generator state to macroengine:output result, so a
# test can capture it, and macroengine:systems/rng/seed can restore it
# later to replay the same sequence.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
execute store result storage macroengine:output result int 1 run data get storage macroengine:engine rng.state
