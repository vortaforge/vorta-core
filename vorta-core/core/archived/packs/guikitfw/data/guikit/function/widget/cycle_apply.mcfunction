# idx into options — walk
execute store result score #i guikit.tmp run data get storage guikit:work idx
execute unless data storage guikit:work opts[0] run return 0
execute if score #i guikit.tmp matches 1.. run function guikit:widget/cycle_apply_skip
execute if data storage guikit:work opts[0].item run data modify storage guikit:draw w.item set from storage guikit:work opts[0].item
