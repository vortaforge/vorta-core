# Euclidean step: a = b, b = a % b — repeat until b is zero
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score $gcd_b macroengine.tmp matches 0 run return 0

scoreboard players operation $gcd_t macroengine.tmp = $gcd_a macroengine.tmp
scoreboard players operation $gcd_a macroengine.tmp = $gcd_b macroengine.tmp
scoreboard players operation $gcd_t macroengine.tmp %= $gcd_b macroengine.tmp
scoreboard players operation $gcd_b macroengine.tmp = $gcd_t macroengine.tmp

function macroengine:core/internal/systems/math/gcd_loop
