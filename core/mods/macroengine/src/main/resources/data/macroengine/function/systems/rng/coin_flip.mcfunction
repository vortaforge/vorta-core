# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/coin_flip [MACRO]
# Flips a fair coin using the seeded generator.
# Output: macroengine:output result → 1b (heads) or 0b (tails)
#
# Example: function macroengine:systems/rng/coin_flip
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
function macroengine:systems/rng/chance {percent:50}
