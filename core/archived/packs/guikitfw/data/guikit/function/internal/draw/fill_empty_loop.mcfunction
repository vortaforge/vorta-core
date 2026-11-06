execute if score #slot guikit.tmp matches 27.. run return 0
execute store result storage guikit:work slot int 1 run scoreboard players get #slot guikit.tmp
function guikit:internal/draw/fill_empty_one with storage guikit:work
scoreboard players add #slot guikit.tmp 1
function guikit:internal/draw/fill_empty_loop
