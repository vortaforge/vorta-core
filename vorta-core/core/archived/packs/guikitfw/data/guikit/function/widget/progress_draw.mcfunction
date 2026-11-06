# macro $(key) — compute filled cells from score/max * width
$execute store result score #cur guikit.tmp run scoreboard players get @s $(key)
scoreboard players set #i guikit.tmp 0
function guikit:widget/progress_cell
