# macro $(key)
$scoreboard players operation @s $(key) += #delta guikit.tmp
$execute if score @s $(key) > #max guikit.tmp run scoreboard players operation @s $(key) = #max guikit.tmp
$execute if score @s $(key) < #min guikit.tmp run scoreboard players operation @s $(key) = #min guikit.tmp
