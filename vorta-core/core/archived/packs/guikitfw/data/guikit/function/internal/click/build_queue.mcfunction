# Fill guikit:work queue with interactive widgets on current page from lib
data modify storage guikit:work queue set value []
execute unless data storage guikit:ctx menu run return 0
data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute unless data storage guikit:draw menu run return 0
execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:internal/draw/load_page with storage guikit:work
data modify storage guikit:work scan set from storage guikit:draw widgets
function guikit:internal/click/build_queue_loop
