# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/dice [MACRO]
# Rolls one die with N sides (1..sides), using the seeded generator.
#  Input : $(sides) — values below 1 are treated as 1
# Output: macroengine:output result → int in 1..sides
#
# Example: function macroengine:systems/rng/dice {sides:6}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
$scoreboard players set $dice_s macroengine.tmp $(sides)
execute if score $dice_s macroengine.tmp matches ..1 run data modify storage macroengine:output result set value 1
execute if score $dice_s macroengine.tmp matches ..1 run return 0
$function macroengine:systems/rng/int {min:1,max:$(sides)}
scoreboard players reset $dice_s macroengine.tmp
