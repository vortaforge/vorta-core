scoreboard players set $team_cnt macroengine.tmp 0
$execute as @a[team=$(team)] run scoreboard players add $team_cnt macroengine.tmp 1
execute store result storage macroengine:output result int 1 run scoreboard players get $team_cnt macroengine.tmp
