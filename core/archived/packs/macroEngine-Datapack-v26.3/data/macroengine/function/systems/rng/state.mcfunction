# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/state
# Copies the current generator state to macroengine:output result, so a
# test can capture it, and macroengine:systems/rng/seed can restore it
# later to replay the same sequence.
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{rng:0b} run return 0
execute store result storage macroengine:output result int 1 run data get storage macroengine:engine rng.state
