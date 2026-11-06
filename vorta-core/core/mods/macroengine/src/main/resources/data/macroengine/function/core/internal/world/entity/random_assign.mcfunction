# ─────────────────────────────────────────────────────────────────
# macroengine:world/entity/internal/random_assign  [INTERNAL]
# Called via "execute as @e[...] run function ..." — runs as each
# matching entity in sequence.
#
# Copies the current counter ($rnd_i macroengine.tmp) into this entity's
# macroengine.rnd_idx score, then increments the counter.
# Because each function call runs to completion before the next
# entity is processed, $rnd_i increments correctly.
#
# Result: entity 1 → macroengine.rnd_idx=0, entity 2 → 1, entity 3 → 2 …
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation @s macroengine.rnd_idx = $rnd_i macroengine.tmp
scoreboard players add $rnd_i macroengine.tmp 1
