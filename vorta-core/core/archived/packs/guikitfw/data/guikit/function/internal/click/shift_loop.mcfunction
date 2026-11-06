execute unless data storage guikit:work queue[0] run return 0
execute if score @s guikit.click matches 1.. run return 0

data remove storage guikit:work id
data remove storage guikit:work type
data modify storage guikit:work id set from storage guikit:work queue[0].id
data modify storage guikit:work type set from storage guikit:work queue[0].kind
execute unless data storage guikit:work id run data modify storage guikit:work id set from storage guikit:work type
execute unless data storage guikit:work type run data modify storage guikit:work type set value "button"

function guikit:internal/click/shift_one with storage guikit:work

data remove storage guikit:work queue[0]
execute if score @s guikit.click matches 0 run function guikit:internal/click/shift_loop
