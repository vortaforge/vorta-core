# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/square [MACRO]
# Squares an integer (value × value).
#  Input : $(value)  — keep |value| ≤ 46340 to avoid 32-bit overflow
# Output: macroengine:output result → int
#
# Example: function macroengine:systems/math/square {value:12}  → 144
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $sq_v macroengine.tmp $(value)
scoreboard players operation $sq_v macroengine.tmp *= $sq_v macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $sq_v macroengine.tmp
scoreboard players reset $sq_v macroengine.tmp
