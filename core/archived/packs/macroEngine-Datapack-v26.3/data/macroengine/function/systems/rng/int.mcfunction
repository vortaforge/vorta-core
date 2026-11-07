# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/int [MACRO]
# Uniform integer in [min, max] inclusive.
#
# INPUT:  $(min), $(max)
# OUTPUT: macroengine:output result
#
# Inverted bounds are swapped rather than rejected. The raw state is
# reduced with abs() before the modulus so a negative state cannot
# produce a result outside the requested range.
#
# Usage:  function macroengine:systems/rng/int {min:1,max:6}
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{rng:0b} run return 0
$scoreboard players set $rng_min macroengine.tmp $(min)
$scoreboard players set $rng_max macroengine.tmp $(max)

execute if score $rng_min macroengine.tmp > $rng_max macroengine.tmp run function macroengine:core/internal/systems/rng/_swap_bounds

scoreboard players operation $rng_span macroengine.tmp = $rng_max macroengine.tmp
scoreboard players operation $rng_span macroengine.tmp -= $rng_min macroengine.tmp
scoreboard players add $rng_span macroengine.tmp 1

function macroengine:core/internal/systems/rng/_core

# INT_MIN has no positive counterpart in a 32-bit score, so fold it to
# INT_MAX first; otherwise the negate below leaves it negative.
execute if score $rng_state macroengine.tmp matches -2147483648 run scoreboard players set $rng_state macroengine.tmp 2147483647
execute if score $rng_state macroengine.tmp matches ..-1 run scoreboard players set $rng_neg macroengine.tmp -1
execute if score $rng_state macroengine.tmp matches ..-1 run scoreboard players operation $rng_state macroengine.tmp *= $rng_neg macroengine.tmp

scoreboard players operation $rng_state macroengine.tmp %= $rng_span macroengine.tmp
scoreboard players operation $rng_state macroengine.tmp += $rng_min macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $rng_state macroengine.tmp
