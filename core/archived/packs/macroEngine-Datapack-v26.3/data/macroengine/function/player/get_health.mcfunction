data modify storage macroengine:output found set value 0b

$execute unless entity @a[name=$(player),limit=1] run return 0

data modify storage macroengine:output found set value 1b
$execute as @a[name=$(player),limit=1] store result storage macroengine:output result int 1 run data get entity @s Health
$execute as @a[name=$(player),limit=1] store result storage macroengine:output max int 1 run data get entity @s Attributes[{Name:"minecraft:max_health"}].Base
