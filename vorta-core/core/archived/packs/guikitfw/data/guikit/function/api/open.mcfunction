# guikit :: api/open
# Input: storage guikit:in {menu:"id", page:0, timer:N}
# Block menus: lib menus.<id>.container is chest|barrel|… and pos:[x,y,z]

scoreboard players set #ok guikit.const 0
execute unless data storage guikit:in menu run return 0

function guikit:internal/open/check
execute unless score #ok guikit.const matches 1 run return 0

execute if score @s guikit.timer matches 1.. run function guikit:api/close

execute unless data storage guikit:in page run data modify storage guikit:in page set value 0
execute unless data storage guikit:in timer run data modify storage guikit:in timer set from storage guikit:cfg timer

execute unless score @s guikit.pid matches 1.. run function guikit:runtime/assign_pid
scoreboard players operation @s guikit.uid = #next_uid guikit.uid
scoreboard players add #next_uid guikit.uid 1

# Load menu def for container type
data modify storage guikit:work id set from storage guikit:in menu
function guikit:internal/draw/load_menu with storage guikit:work
function guikit:internal/container/is_block

execute if score #block guikit.tmp matches 1 run function guikit:internal/container/open_block
execute if score #block guikit.tmp matches 0 run function guikit:internal/container/open_entity
execute unless score #ok guikit.const matches 1 run return 0

execute store result score @s guikit.page run data get storage guikit:in page
execute store result score @s guikit.timer run data get storage guikit:in timer
scoreboard players operation @s guikit.tmax = @s guikit.timer
scoreboard players set @s guikit.drop 0
data modify storage guikit:ctx menu set from storage guikit:in menu
function guikit:runtime/last_record

function #guikit:on_open
function guikit:runtime/menu_hooks_open
scoreboard players set @s guikit.dirty 1
function guikit:internal/draw/redraw

data remove storage guikit:in page
data remove storage guikit:in timer
scoreboard players set #ok guikit.const 1
