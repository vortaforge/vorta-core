# macroengine:core/internal/systems/rng/_swap_bounds
# min > max is a caller mistake, not an error: swap and carry on, so
# {min:10,max:1} behaves like {min:1,max:10} instead of producing
# nothing at all.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation $rng_swap macroengine.tmp = $rng_min macroengine.tmp
scoreboard players operation $rng_min macroengine.tmp = $rng_max macroengine.tmp
scoreboard players operation $rng_max macroengine.tmp = $rng_swap macroengine.tmp
