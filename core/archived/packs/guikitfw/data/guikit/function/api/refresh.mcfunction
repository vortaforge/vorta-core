# Force redraw for @s without reopening
execute unless score @s guikit.timer matches 1.. run return 0
scoreboard players set @s guikit.dirty 1
function guikit:internal/draw/redraw
