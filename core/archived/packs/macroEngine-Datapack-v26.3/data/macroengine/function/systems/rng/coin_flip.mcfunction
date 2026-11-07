# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/coin_flip [MACRO]
# Flips a fair coin using the seeded generator.
# Output: macroengine:output result → 1b (heads) or 0b (tails)
#
# Example: function macroengine:systems/rng/coin_flip
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{rng:0b} run return 0
function macroengine:systems/rng/chance {percent:50}
