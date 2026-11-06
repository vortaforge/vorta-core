# macro $(slot) $(item) $(id) $(type) $(menu) — also uses work x y z when mode=1
execute if score @s guikit.mode matches 1 run function guikit:internal/container/load_pos
execute if score @s guikit.mode matches 1 run function guikit:widget/_place_do_block with storage guikit:work
execute unless score @s guikit.mode matches 1 run function guikit:widget/_place_do_entity with storage guikit:work
