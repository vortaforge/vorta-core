# AS dropped GUI item entity (guigen drop)
data modify storage guikit:work thrower set from entity @s Thrower
tag @a remove guikit.thrower
execute as @a[scores={guikit.timer=1..,guikit.click=0}] run function guikit:internal/click/drop_match
# Read id/type from item custom_data into work
data remove storage guikit:work id
data remove storage guikit:work type
data modify storage guikit:work id set from entity @s Item.components."minecraft:custom_data".guikit.id
data modify storage guikit:work type set from entity @s Item.components."minecraft:custom_data".guikit.type
execute unless data storage guikit:work id run return run kill @s
execute as @a[tag=guikit.thrower,limit=1] at @s run function guikit:internal/click/drop_run
tag @a remove guikit.thrower
kill @s
