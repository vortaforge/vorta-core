execute unless data storage guikit:work queue[0] run return 0
execute if score @s guikit.click matches 1.. run return 0

data remove storage guikit:work id
data remove storage guikit:work type
data remove storage guikit:work slot
data modify storage guikit:work id set from storage guikit:work queue[0].id
data modify storage guikit:work type set from storage guikit:work queue[0].kind
execute unless data storage guikit:work id run data modify storage guikit:work id set from storage guikit:work type
execute unless data storage guikit:work type run data modify storage guikit:work type set value "button"
execute store result storage guikit:work slot int 1 run data get storage guikit:work queue[0].slot

function guikit:internal/click/left_one with storage guikit:work

data remove storage guikit:work queue[0]
execute if score @s guikit.click matches 0 run function guikit:internal/click/left_loop
