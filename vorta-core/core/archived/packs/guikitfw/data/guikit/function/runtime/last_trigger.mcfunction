scoreboard players set @s guikit.last 0
scoreboard players enable @s guikit.last
execute unless score @s guikit.pid matches 1.. run function guikit:runtime/assign_pid
execute store result storage guikit:work pid int 1 run scoreboard players get @s guikit.pid
data remove storage guikit:work menu
function guikit:runtime/last_load with storage guikit:work
execute unless data storage guikit:work menu run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"You have not opened a menu yet.","color":"red"}]
execute unless data storage guikit:work menu run return 0
data modify storage guikit:in menu set from storage guikit:work menu
function guikit:internal/open/check
execute unless score #ok guikit.const matches 1 run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Saved menu no longer exists.","color":"red"}]
execute unless score #ok guikit.const matches 1 run return 0
function guikit:api/open
