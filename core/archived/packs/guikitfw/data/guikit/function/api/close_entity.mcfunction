function guikit:internal/bind/me
function guikit:runtime/menu_hooks_close
function #guikit:on_close
execute as @e[type=#guikit:container,tag=guikit.me,limit=1] run data modify entity @s Items set value []
kill @e[type=#guikit:container,tag=guikit.me]
clear @s *[custom_data~{guikit:{widget:1}}]
scoreboard players reset @s guikit.timer
scoreboard players reset @s guikit.page
scoreboard players reset @s guikit.click
scoreboard players reset @s guikit.uid
scoreboard players reset @s guikit.mode
data remove storage guikit:ctx menu
data remove storage guikit:ctx actions
data remove storage guikit:ctx click
