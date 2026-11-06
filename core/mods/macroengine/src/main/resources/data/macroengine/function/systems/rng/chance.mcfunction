# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/chance [MACRO]
# Writes 1 to macroengine:output result with probability percent/100,
# otherwise 0.
#
# INPUT: $(percent) — clamped, so 0 always yields 0 and 100+ always 1
#
# Usage:  function macroengine:systems/rng/chance {percent:25}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
$scoreboard players set $rng_pct macroengine.tmp $(percent)

execute if score $rng_pct macroengine.tmp matches ..0 run data modify storage macroengine:output result set value 0
execute if score $rng_pct macroengine.tmp matches ..0 run return 0
execute if score $rng_pct macroengine.tmp matches 100.. run data modify storage macroengine:output result set value 1
execute if score $rng_pct macroengine.tmp matches 100.. run return 0

function macroengine:systems/rng/int {min:0,max:99}
execute store result score $rng_roll macroengine.tmp run data get storage macroengine:output result

execute if score $rng_roll macroengine.tmp < $rng_pct macroengine.tmp run data modify storage macroengine:output result set value 1
execute unless score $rng_roll macroengine.tmp < $rng_pct macroengine.tmp run data modify storage macroengine:output result set value 0

scoreboard players reset $rng_pct macroengine.tmp
scoreboard players reset $rng_roll macroengine.tmp
