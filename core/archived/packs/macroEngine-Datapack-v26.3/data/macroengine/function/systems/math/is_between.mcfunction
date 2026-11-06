# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/is_between
# Checks if value is in the inclusive range [min, max].
#  Input : $(value), $(min), $(max)
# Output: macroengine:output result → 1b (true) or 0b (false)
#
# Example:
# data modify storage macroengine:input value set value 15
# data modify storage macroengine:input min set value 10
# data modify storage macroengine:input max set value 20
# function macroengine:systems/math/is_between with storage macroengine:input {}
# macroengine:output result = 1b
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $ib_v macroengine.tmp $(value)
$scoreboard players set $ib_lo macroengine.tmp $(min)
$scoreboard players set $ib_hi macroengine.tmp $(max)

data modify storage macroengine:output result set value 0b

execute if score $ib_v macroengine.tmp >= $ib_lo macroengine.tmp run execute if score $ib_v macroengine.tmp <= $ib_hi macroengine.tmp run data modify storage macroengine:output result set value 1b
