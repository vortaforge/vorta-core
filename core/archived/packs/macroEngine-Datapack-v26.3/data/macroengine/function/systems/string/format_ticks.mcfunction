execute if data storage macroengine:engine modules{string:0b} run return 0
$scoreboard players set $ft_t macroengine.tmp $(ticks)

scoreboard players set $ft_20 macroengine.tmp 20
scoreboard players operation $ft_s macroengine.tmp = $ft_t macroengine.tmp
scoreboard players operation $ft_s macroengine.tmp /= $ft_20 macroengine.tmp

execute store result storage macroengine:output total_seconds int 1 run scoreboard players get $ft_s macroengine.tmp

scoreboard players set $ft_60 macroengine.tmp 60
scoreboard players operation $ft_m macroengine.tmp = $ft_s macroengine.tmp
scoreboard players operation $ft_m macroengine.tmp /= $ft_60 macroengine.tmp

scoreboard players operation $ft_s macroengine.tmp %= $ft_60 macroengine.tmp

execute store result storage macroengine:output minutes int 1 run scoreboard players get $ft_m macroengine.tmp
execute store result storage macroengine:output seconds int 1 run scoreboard players get $ft_s macroengine.tmp
