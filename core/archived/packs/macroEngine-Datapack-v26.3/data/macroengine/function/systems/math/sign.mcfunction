execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $sign_v macroengine.tmp $(value)
execute if score $sign_v macroengine.tmp matches 1.. run data modify storage macroengine:output result set value 1
execute if score $sign_v macroengine.tmp matches 0 run data modify storage macroengine:output result set value 0
execute if score $sign_v macroengine.tmp matches ..-1 run data modify storage macroengine:output result set value -1
