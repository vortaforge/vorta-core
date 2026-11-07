data modify storage macroengine:output result set value 1b

$execute unless data storage macroengine:engine cooldowns.$(player).$(key) run return 0

$execute store result score $cd_exp macroengine.tmp run data get storage macroengine:engine cooldowns.$(player).$(key)
execute store result score $cd_now macroengine.tmp run scoreboard players get $epoch macroengine.time

execute if score $cd_now macroengine.tmp < $cd_exp macroengine.tmp run data modify storage macroengine:output result set value 0b