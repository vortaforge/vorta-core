# w.progress_score, progress_max, progress_width, full/empty items
data modify storage guikit:work key set from storage guikit:draw w.progress_score
execute unless data storage guikit:work key run data modify storage guikit:work key set from storage guikit:draw w.key
execute store result score #max guikit.tmp run data get storage guikit:draw w.progress_max
execute unless score #max guikit.tmp matches 1.. run scoreboard players set #max guikit.tmp 10
execute store result score #width guikit.tmp run data get storage guikit:draw w.progress_width
execute unless score #width guikit.tmp matches 1.. run scoreboard players set #width guikit.tmp 5
execute store result score #base guikit.tmp run data get storage guikit:draw w.slot
data modify storage guikit:work full set from storage guikit:draw w.progress_full_item
data modify storage guikit:work empty set from storage guikit:draw w.progress_empty_item
execute unless data storage guikit:work full run data modify storage guikit:work full set value "minecraft:lime_stained_glass_pane"
execute unless data storage guikit:work empty run data modify storage guikit:work empty set value "minecraft:gray_stained_glass_pane"
execute if data storage guikit:work key run function guikit:widget/progress_draw with storage guikit:work
