execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if score $rn_i macroengine.tmp >= $rn_n macroengine.tmp run return 0

execute store result score $repeat_i macroengine.tmp run scoreboard players get $rn_i macroengine.tmp
function macroengine:core/internal/core/lib/repeat_n_call with storage macroengine:engine {}
scoreboard players add $rn_i macroengine.tmp 1
function macroengine:core/internal/core/lib/repeat_n_loop
