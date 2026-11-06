# Place block container at menu.pos [x,y,z] (or menu.container.pos)
# Sets player guikit.bx/by/bz and mode=1
data remove storage guikit:work pos
data modify storage guikit:work pos set from storage guikit:draw menu.pos
execute if data storage guikit:draw menu.container.pos run data modify storage guikit:work pos set from storage guikit:draw menu.container.pos
execute unless data storage guikit:work pos[2] run return run function guikit:internal/open/fail_pos

execute store result score @s guikit.bx run data get storage guikit:work pos[0]
execute store result score @s guikit.by run data get storage guikit:work pos[1]
execute store result score @s guikit.bz run data get storage guikit:work pos[2]
scoreboard players set @s guikit.mode 1

data modify storage guikit:work ctype set value "chest"
execute if data storage guikit:draw menu.container run data modify storage guikit:work ctype set from storage guikit:draw menu.container
execute if data storage guikit:draw menu.container.type run data modify storage guikit:work ctype set from storage guikit:draw menu.container.type

# macro coords + setblock
execute store result storage guikit:work x int 1 run scoreboard players get @s guikit.bx
execute store result storage guikit:work y int 1 run scoreboard players get @s guikit.by
execute store result storage guikit:work z int 1 run scoreboard players get @s guikit.bz
function guikit:internal/container/setblock_do with storage guikit:work
