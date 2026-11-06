# ======================================================================================
# macroengine:systems/math/median3 [MACRO]
# Median (middle value) of three integers. Uses compare-and-swap, so there is no
# overflow risk like a (a + b + c - min - max) formula would have.
#
# INPUT:  $(a), $(b), $(c)  integers
# OUTPUT: macroengine:output result
#
# Example: function macroengine:systems/math/median3 {a:9,b:2,c:5}  -> result = 5
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set #ext_m_a macroengine.tmp $(a)
$scoreboard players set #ext_m_b macroengine.tmp $(b)
$scoreboard players set #ext_m_c macroengine.tmp $(c)
execute if score #ext_m_a macroengine.tmp > #ext_m_b macroengine.tmp run scoreboard players operation #ext_m_a macroengine.tmp >< #ext_m_b macroengine.tmp
execute if score #ext_m_b macroengine.tmp > #ext_m_c macroengine.tmp run scoreboard players operation #ext_m_b macroengine.tmp >< #ext_m_c macroengine.tmp
execute if score #ext_m_a macroengine.tmp > #ext_m_b macroengine.tmp run scoreboard players operation #ext_m_a macroengine.tmp >< #ext_m_b macroengine.tmp
execute store result storage macroengine:output result int 1 run scoreboard players get #ext_m_b macroengine.tmp
