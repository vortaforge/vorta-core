# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/systems/rng/_auto_seed
# First-use seeding. Called only when rng.state does not exist yet, so
# an explicitly seeded run is never overwritten.
#
# gametime is a weak seed: two servers started at the same tick produce
# the same stream. Call systems/rng/seed when reproducibility matters.
# ─────────────────────────────────────────────────────────────────

execute store result score $rng_seed_tmp macroengine.tmp run time query gametime
scoreboard players add $rng_seed_tmp macroengine.tmp 57005
execute store result storage macroengine:engine rng.state int 1 run scoreboard players get $rng_seed_tmp macroengine.tmp
scoreboard players reset $rng_seed_tmp macroengine.tmp
