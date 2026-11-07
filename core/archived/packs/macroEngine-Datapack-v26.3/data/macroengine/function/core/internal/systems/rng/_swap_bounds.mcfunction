# macroengine:core/internal/systems/rng/_swap_bounds
# min > max is a caller mistake, not an error: swap and carry on, so
# {min:10,max:1} behaves like {min:1,max:10} instead of producing
# nothing at all.

scoreboard players operation $rng_swap macroengine.tmp = $rng_min macroengine.tmp
scoreboard players operation $rng_min macroengine.tmp = $rng_max macroengine.tmp
scoreboard players operation $rng_max macroengine.tmp = $rng_swap macroengine.tmp
