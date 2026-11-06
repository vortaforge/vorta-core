execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score $lg2_v macroengine.tmp matches ..1 run return 0

scoreboard players add $lg2_r macroengine.tmp 1
scoreboard players operation $lg2_v macroengine.tmp /= $lg2_2 macroengine.tmp

function macroengine:core/internal/systems/math/log2_loop
