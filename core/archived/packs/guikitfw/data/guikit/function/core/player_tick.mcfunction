# bind → click → vacuum → fill
execute if score @s guikit.mode matches 1 run function guikit:core/player_tick_block
execute unless score @s guikit.mode matches 1 run function guikit:core/player_tick_entity
