# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/is_even [MACRO]
# Checks whether an integer is even.
#  Input : $(value)
# Output: macroengine:output result → 1b (even) or 0b (odd)
#
# Example: function macroengine:systems/math/is_even {value:42}  → 1b
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $ie_v macroengine.tmp $(value)
scoreboard players set $ie_2 macroengine.tmp 2
scoreboard players operation $ie_v macroengine.tmp %= $ie_2 macroengine.tmp
data modify storage macroengine:output result set value 0b
execute if score $ie_v macroengine.tmp matches 0 run data modify storage macroengine:output result set value 1b
scoreboard players reset $ie_v macroengine.tmp
scoreboard players reset $ie_2 macroengine.tmp
