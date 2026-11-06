execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output found set value 0b

$execute unless entity @a[name=$(player),limit=1] run return 0

data modify storage macroengine:output found set value 1b
$execute as @a[name=$(player),limit=1] store result storage macroengine:output level int 1 run data get entity @s XpLevel
$execute as @a[name=$(player),limit=1] store result storage macroengine:output points int 1 run xp query @s points
$execute as @a[name=$(player),limit=1] store result storage macroengine:output progress int 1000 run data get entity @s XpP
