data remove storage guikit:work opts[0]
scoreboard players remove #i guikit.tmp 1
execute if score #i guikit.tmp matches 1.. if data storage guikit:work opts[0] run function guikit:widget/cycle_apply_skip
