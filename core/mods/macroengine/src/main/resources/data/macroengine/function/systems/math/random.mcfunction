# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/random [MACRO]
# Uniform integer in [min, max] inclusive.
#
# INPUT:  $(min), $(max) — supplied by the caller's own `with storage`
# OUTPUT: macroengine:output result
#
# Thin wrapper kept for compatibility: callers still pass min/max through
# whatever storage compound they already use. The generator itself now
# lives in systems/rng, so seeding and state capture are shared instead
# of duplicated:
#
#   function macroengine:systems/rng/seed {seed:12345}
#
# Before this, the generator held its own undocumented `_rng_state` key
# with no way to seed it, so no randomised behaviour in the pack could be
# reproduced.
#
# Usage:  function macroengine:systems/math/random {min:1,max:6}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$function macroengine:systems/rng/int {min:$(min),max:$(max)}
