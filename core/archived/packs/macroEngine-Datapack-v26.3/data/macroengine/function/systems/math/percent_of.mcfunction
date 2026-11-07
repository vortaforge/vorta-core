# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/percent_of [MACRO]
# Computes percent% of value (integer division, rounds toward zero).
#  Input : $(value), $(percent) — keep |value × percent| ≤ 2147483647
# Output: macroengine:output result → int
#
# Example: function macroengine:systems/math/percent_of {value:250,percent:20}  → 50
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $po_v macroengine.tmp $(value)
$scoreboard players set $po_p macroengine.tmp $(percent)
scoreboard players set $po_100 macroengine.tmp 100
scoreboard players operation $po_v macroengine.tmp *= $po_p macroengine.tmp
scoreboard players operation $po_v macroengine.tmp /= $po_100 macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $po_v macroengine.tmp
scoreboard players reset $po_v macroengine.tmp
scoreboard players reset $po_p macroengine.tmp
scoreboard players reset $po_100 macroengine.tmp
