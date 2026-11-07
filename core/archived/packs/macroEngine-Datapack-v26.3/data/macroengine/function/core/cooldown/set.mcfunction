$scoreboard players set $cd_dur macroengine.tmp $(duration)
execute store result score $cd_now macroengine.tmp run scoreboard players get $epoch macroengine.time
scoreboard players operation $cd_now macroengine.tmp += $cd_dur macroengine.tmp
$execute store result storage macroengine:engine cooldowns.$(player).$(key) int 1 run scoreboard players get $cd_now macroengine.tmp