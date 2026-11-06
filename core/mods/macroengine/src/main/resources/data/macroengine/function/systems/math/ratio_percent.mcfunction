# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/ratio_percent [MACRO]
# Computes what percent part is of total (integer, rounds toward zero).
#  Input : $(part), $(total) — keep |part| ≤ 21474836; total 0 yields 0
# Output: macroengine:output result → int
#
# Example: function macroengine:systems/math/ratio_percent {part:3,total:12}  → 25
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $rp_a macroengine.tmp $(part)
$scoreboard players set $rp_b macroengine.tmp $(total)
execute if score $rp_b macroengine.tmp matches 0 run data modify storage macroengine:output result set value 0
execute if score $rp_b macroengine.tmp matches 0 run return 0
scoreboard players set $rp_100 macroengine.tmp 100
scoreboard players operation $rp_a macroengine.tmp *= $rp_100 macroengine.tmp
scoreboard players operation $rp_a macroengine.tmp /= $rp_b macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get $rp_a macroengine.tmp
scoreboard players reset $rp_a macroengine.tmp
scoreboard players reset $rp_b macroengine.tmp
scoreboard players reset $rp_100 macroengine.tmp
