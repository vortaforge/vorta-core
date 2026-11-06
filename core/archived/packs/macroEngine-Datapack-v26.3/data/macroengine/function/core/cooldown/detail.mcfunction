execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data merge storage macroengine:output {active:0b,remaining:0,expires:0}

$execute unless data storage macroengine:engine cooldowns.$(player).$(key) run return 0

$execute store result score $cdd_exp macroengine.tmp run data get storage macroengine:engine cooldowns.$(player).$(key)
execute store result storage macroengine:output expires int 1 run scoreboard players get $cdd_exp macroengine.tmp

execute store result score $cdd_now macroengine.tmp run scoreboard players get $epoch macroengine.time

execute if score $cdd_now macroengine.tmp < $cdd_exp macroengine.tmp run data modify storage macroengine:output active set value 1b

scoreboard players operation $cdd_exp macroengine.tmp -= $cdd_now macroengine.tmp
execute if score $cdd_exp macroengine.tmp matches 1.. run execute store result storage macroengine:output remaining int 1 run scoreboard players get $cdd_exp macroengine.tmp