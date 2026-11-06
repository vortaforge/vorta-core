execute unless score @s guikit.timer matches 1.. run return 0
execute if score @s guikit.mode matches 1 run function guikit:api/close_block
execute unless score @s guikit.mode matches 1 run function guikit:api/close_entity
