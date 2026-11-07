# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/systems/rng/_core
# Advances the generator by one step and leaves the new raw state in
# $rng_state macroengine.tmp. Bounded output is the caller's job.
#
# Linear congruential generator, state = state * 1664525 + 1013904223
# (mod 2^32, which is what scoreboard overflow gives for free). The
# constants are the Numerical Recipes ones; the full 32-bit state is
# kept, and callers discard the low bits they do not trust by taking a
# modulus over the range they actually need.
# ─────────────────────────────────────────────────────────────────

execute unless data storage macroengine:engine rng.state run function macroengine:core/internal/systems/rng/_auto_seed

execute store result score $rng_state macroengine.tmp run data get storage macroengine:engine rng.state

scoreboard players set $rng_lcg_a macroengine.tmp 1664525
scoreboard players set $rng_lcg_c macroengine.tmp 1013904223
scoreboard players operation $rng_state macroengine.tmp *= $rng_lcg_a macroengine.tmp
scoreboard players operation $rng_state macroengine.tmp += $rng_lcg_c macroengine.tmp

execute store result storage macroengine:engine rng.state int 1 run scoreboard players get $rng_state macroengine.tmp
