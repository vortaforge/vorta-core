execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score $next_pid macroengine.tmp run data get storage macroengine:engine _pid_seq

scoreboard players add $next_pid macroengine.tmp 1

$execute store result storage macroengine:engine player_pids.$(player) int 1 run scoreboard players get $next_pid macroengine.tmp
$scoreboard players operation @a[name=$(player),limit=1] macroengine.pid = $next_pid macroengine.tmp

execute store result storage macroengine:engine _pid_seq int 1 run scoreboard players get $next_pid macroengine.tmp