execute if data storage macroengine:engine modules{math:0b} run return 0
$scoreboard players set $dvm_v macroengine.tmp $(value)
$scoreboard players set $dvm_d macroengine.tmp $(divisor)

execute if score $dvm_d macroengine.tmp matches ..0 run data modify storage macroengine:output quotient set value 0
execute if score $dvm_d macroengine.tmp matches ..0 run data modify storage macroengine:output remainder set value 0
execute if score $dvm_d macroengine.tmp matches ..0 run return 0

scoreboard players operation $dvm_q macroengine.tmp = $dvm_v macroengine.tmp
scoreboard players operation $dvm_q macroengine.tmp /= $dvm_d macroengine.tmp
execute store result storage macroengine:output quotient int 1 run scoreboard players get $dvm_q macroengine.tmp

scoreboard players operation $dvm_v macroengine.tmp %= $dvm_d macroengine.tmp
execute if score $dvm_v macroengine.tmp matches ..-1 run scoreboard players operation $dvm_v macroengine.tmp += $dvm_d macroengine.tmp
execute store result storage macroengine:output remainder int 1 run scoreboard players get $dvm_v macroengine.tmp
