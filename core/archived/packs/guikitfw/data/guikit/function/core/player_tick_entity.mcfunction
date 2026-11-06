function guikit:internal/bind/me

execute if data storage guikit:cfg {follow:1b} as @e[type=#guikit:container,tag=guikit.me,limit=1] run tp @s ~ ~1.2 ~
execute unless data storage guikit:cfg {follow:1b} unless entity @e[type=#guikit:container,tag=guikit.me,distance=..8,limit=1] run return run function guikit:api/close
execute unless entity @e[type=#guikit:container,tag=guikit.me,limit=1] run return run function guikit:api/close
execute unless score @s guikit.timer matches 1.. run return 0

scoreboard players set @s guikit.click 0
data remove storage guikit:ctx click

function guikit:internal/click/build_queue
function guikit:internal/click/shift
execute if score @s guikit.click matches 0 run function guikit:internal/click/maybe_left

clear @s *[custom_data~{guikit:{widget:1}}]
execute if items entity @s player.cursor *[minecraft:custom_data~{guikit:{}}] run item replace entity @s player.cursor with minecraft:air

function guikit:internal/draw/redraw
