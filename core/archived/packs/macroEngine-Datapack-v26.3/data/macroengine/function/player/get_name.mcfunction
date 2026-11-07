# macroengine:player/get_name
# Resolves the executor's profile name and UUID into macroengine:names temp.
# Uses a short-lived marker armor_stand at the execution position instead of a block,
# so no world position (and no loaded chunk at a fixed coordinate) is required.
data remove storage macroengine:names temp

summon minecraft:armor_stand ~ ~ ~ {Tags:["macroengine.name_tmp"],Invisible:1b,Marker:1b,NoGravity:1b,Silent:1b,Invulnerable:1b}

loot replace entity @e[type=minecraft:armor_stand,tag=macroengine.name_tmp,sort=nearest,limit=1] armor.head loot macroengine:player/head

data modify storage macroengine:names temp.NAME set from entity @e[type=minecraft:armor_stand,tag=macroengine.name_tmp,sort=nearest,limit=1] equipment.head.components."minecraft:profile".name

data modify storage macroengine:names temp.UUID insert 0 from entity @s UUID[0]
data modify storage macroengine:names temp.UUID insert 1 from entity @s UUID[1]
data modify storage macroengine:names temp.UUID insert 2 from entity @s UUID[2]
data modify storage macroengine:names temp.UUID insert 3 from entity @s UUID[3]

kill @e[type=minecraft:armor_stand,tag=macroengine.name_tmp]
