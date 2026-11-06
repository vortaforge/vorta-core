function guikit:internal/container/load_pos
# presence
function guikit:internal/container/block_present
execute unless score #present guikit.tmp matches 1 run return run function guikit:api/close

data modify storage guikit:ctx actions set value []
data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute unless data storage guikit:draw menu run return 0

execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:internal/draw/load_page with storage guikit:work

function guikit:internal/container/clear_block with storage guikit:work
execute if data storage guikit:draw widgets[0] run function guikit:internal/draw/loop
function guikit:internal/draw/fill_empty
function #guikit:fill
