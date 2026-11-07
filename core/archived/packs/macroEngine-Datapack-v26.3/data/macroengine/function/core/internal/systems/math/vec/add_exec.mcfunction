# macroengine:systems/math/vec/internal/add_exec [MACRO]
# INPUT: $(ax), $(ay), $(az), $(bx), $(by), $(bz)

$scoreboard players set $vx macroengine.tmp $(ax)
$scoreboard players set $vy macroengine.tmp $(ay)
$scoreboard players set $vz macroengine.tmp $(az)
$scoreboard players add $vx macroengine.tmp $(bx)
$scoreboard players add $vy macroengine.tmp $(by)
$scoreboard players add $vz macroengine.tmp $(bz)

execute store result storage macroengine:output x int 1 run scoreboard players get $vx macroengine.tmp
execute store result storage macroengine:output y int 1 run scoreboard players get $vy macroengine.tmp
execute store result storage macroengine:output z int 1 run scoreboard players get $vz macroengine.tmp