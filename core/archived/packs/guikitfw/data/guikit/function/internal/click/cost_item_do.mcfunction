# macro $(citem) $(ccount)
$execute store result score #has guikit.tmp run clear @s $(citem) 0
$execute unless score #has guikit.tmp matches $(ccount).. run scoreboard players set #cost_fail guikit.tmp 1
$execute if score #cost_fail guikit.tmp matches 0 run clear @s $(citem) $(ccount)
