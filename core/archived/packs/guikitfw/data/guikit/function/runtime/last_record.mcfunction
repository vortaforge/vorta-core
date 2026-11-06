# Remember last menu id for /trigger guikit.last (per pid in storage)
execute store result storage guikit:work pid int 1 run scoreboard players get @s guikit.pid
data modify storage guikit:work menu set from storage guikit:in menu
function guikit:runtime/last_store with storage guikit:work
