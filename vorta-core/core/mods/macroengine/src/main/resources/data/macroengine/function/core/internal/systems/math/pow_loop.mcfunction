execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score $pow_n macroengine.tmp matches ..0 run return 0
scoreboard players operation $pow_r macroengine.tmp *= $pow_a macroengine.tmp
scoreboard players remove $pow_n macroengine.tmp 1
function macroengine:core/internal/systems/math/pow_loop
