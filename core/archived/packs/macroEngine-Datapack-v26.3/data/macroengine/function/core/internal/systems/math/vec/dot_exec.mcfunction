# macroengine:systems/math/vec/internal/dot_exec [MACRO]
# INPUT: $(ax), $(ay), $(az), $(bx), $(by), $(bz)

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set $vdax macroengine.tmp $(ax)
$scoreboard players set $vdbx macroengine.tmp $(bx)
scoreboard players operation $vdax macroengine.tmp *= $vdbx macroengine.tmp

$scoreboard players set $vday macroengine.tmp $(ay)
$scoreboard players set $vdby macroengine.tmp $(by)
scoreboard players operation $vday macroengine.tmp *= $vdby macroengine.tmp

$scoreboard players set $vdaz macroengine.tmp $(az)
$scoreboard players set $vdbz macroengine.tmp $(bz)
scoreboard players operation $vdaz macroengine.tmp *= $vdbz macroengine.tmp

scoreboard players operation $vdax macroengine.tmp += $vday macroengine.tmp
scoreboard players operation $vdax macroengine.tmp += $vdaz macroengine.tmp

execute store result storage macroengine:output result int 1 run scoreboard players get $vdax macroengine.tmp