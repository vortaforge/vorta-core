execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set $rn_n macroengine.tmp $(n)
scoreboard players set $rn_i macroengine.tmp 0

execute if score $rn_n macroengine.tmp matches ..0 run return 0

$data modify storage macroengine:engine _rn_func set value "$(func)"
function macroengine:core/internal/core/lib/repeat_n_loop
data remove storage macroengine:engine _rn_func
