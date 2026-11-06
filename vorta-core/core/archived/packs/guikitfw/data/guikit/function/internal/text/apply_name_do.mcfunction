# macro $(slot) $(item) $(id) $(type) $(menu) $(ntext)
execute if score @s guikit.mode matches 1 run function guikit:internal/container/load_pos
execute if score @s guikit.mode matches 1 run function guikit:internal/text/apply_name_block with storage guikit:work
execute unless score @s guikit.mode matches 1 run function guikit:internal/text/apply_name_entity with storage guikit:work
