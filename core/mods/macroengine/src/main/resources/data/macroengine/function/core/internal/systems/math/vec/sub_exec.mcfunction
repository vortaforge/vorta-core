# macroengine:systems/math/vec/internal/sub_exec [MACRO]
# INPUT: $(ax), $(ay), $(az), $(bx), $(by), $(bz)

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set $vx macroengine.tmp $(ax)
$scoreboard players set $vy macroengine.tmp $(ay)
$scoreboard players set $vz macroengine.tmp $(az)
$scoreboard players remove $vx macroengine.tmp $(bx)
$scoreboard players remove $vy macroengine.tmp $(by)
$scoreboard players remove $vz macroengine.tmp $(bz)

execute store result storage macroengine:output x int 1 run scoreboard players get $vx macroengine.tmp
execute store result storage macroengine:output y int 1 run scoreboard players get $vy macroengine.tmp
execute store result storage macroengine:output z int 1 run scoreboard players get $vz macroengine.tmp