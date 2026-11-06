function guikit:internal/bind/me
execute unless entity @e[type=#guikit:container,tag=guikit.me,limit=1] run return 0

data modify storage guikit:ctx actions set value []
data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute unless data storage guikit:draw menu run return 0

execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:internal/draw/load_page with storage guikit:work

execute as @e[type=#guikit:container,tag=guikit.me,limit=1] run data modify entity @s Items set value []
execute if data storage guikit:draw widgets[0] run function guikit:internal/draw/loop
function guikit:internal/draw/fill_empty
function #guikit:fill
