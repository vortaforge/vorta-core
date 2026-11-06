# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/seed [MACRO]
# Sets the generator state explicitly. Two runs started from the same
# seed produce the same sequence, which is what makes randomised
# behaviour testable.
#
# INPUT: $(seed) — any integer
#
# Usage:  function macroengine:systems/rng/seed {seed:12345}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
$scoreboard players set $rng_seed macroengine.tmp $(seed)
execute store result storage macroengine:engine rng.state int 1 run scoreboard players get $rng_seed macroengine.tmp
scoreboard players reset $rng_seed macroengine.tmp
