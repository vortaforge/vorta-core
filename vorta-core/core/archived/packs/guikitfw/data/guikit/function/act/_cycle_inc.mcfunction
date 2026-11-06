# macro $(key)
$scoreboard players add @s $(key) 1
$execute if score @s $(key) > #max guikit.tmp run scoreboard players set @s $(key) 0
