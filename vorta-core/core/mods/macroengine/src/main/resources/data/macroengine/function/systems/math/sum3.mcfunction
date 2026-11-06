# ─────────────────────────────────────────────────────────────────
# macroengine:systems/math/sum3
# Adds three integers with INT_MAX overflow guard.
#  Input : $(a), $(b), $(c)
# Output: macroengine:output result → a + b + c (clamped to 2147483647)
#
# Example:
# data modify storage macroengine:input a set value 100
# data modify storage macroengine:input b set value 200
# data modify storage macroengine:input c set value 300
# function macroengine:systems/math/sum3 with storage macroengine:input {}
# macroengine:output result = 600
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $s3_a macroengine.tmp $(a)
$scoreboard players set $s3_b macroengine.tmp $(b)
$scoreboard players set $s3_c macroengine.tmp $(c)

scoreboard players operation $s3_a macroengine.tmp += $s3_b macroengine.tmp
# Overflow clamp after first add
execute if score $s3_a macroengine.tmp matches 2147483647.. run scoreboard players set $s3_a macroengine.tmp 2147483647

scoreboard players operation $s3_a macroengine.tmp += $s3_c macroengine.tmp
# Overflow clamp after second add
execute if score $s3_a macroengine.tmp matches 2147483647.. run scoreboard players set $s3_a macroengine.tmp 2147483647

execute store result storage macroengine:output result int 1 run scoreboard players get $s3_a macroengine.tmp
