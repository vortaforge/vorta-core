# macro $(slot) $(filler)
data modify storage guikit:work item set from storage guikit:work filler
execute if score @s guikit.mode matches 1 run function guikit:internal/container/load_pos
execute if score @s guikit.mode matches 1 run function guikit:internal/draw/fill_empty_block with storage guikit:work
execute unless score @s guikit.mode matches 1 run function guikit:internal/draw/fill_empty_entity with storage guikit:work
