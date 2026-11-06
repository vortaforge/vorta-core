# macro $(id) $(type) $(slot)
execute if score @s guikit.mode matches 1 run function guikit:internal/container/load_pos
execute if score @s guikit.mode matches 1 run function guikit:internal/click/left_one_block with storage guikit:work
execute unless score @s guikit.mode matches 1 run function guikit:internal/click/left_one_entity with storage guikit:work
