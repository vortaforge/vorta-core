# Kiosk: distance + block presence (guigen block path)
execute unless score @s guikit.timer matches 1.. run return 0
function guikit:internal/container/load_pos
function guikit:internal/container/block_present
execute unless score #present guikit.tmp matches 1 run return run function guikit:api/close
# distance_close (default 8)
function guikit:internal/container/block_distance
execute if score #far guikit.tmp matches 1 run return run function guikit:api/close

scoreboard players set @s guikit.click 0
data remove storage guikit:ctx click

function guikit:internal/click/build_queue
function guikit:internal/click/shift
execute if score @s guikit.click matches 0 run function guikit:internal/click/maybe_left

clear @s *[custom_data~{guikit:{widget:1}}]
execute if items entity @s player.cursor *[minecraft:custom_data~{guikit:{}}] run item replace entity @s player.cursor with minecraft:air

function guikit:internal/draw/redraw
