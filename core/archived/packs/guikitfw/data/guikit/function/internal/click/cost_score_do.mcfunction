# macro $(cscore)
$execute unless score @s $(cscore) >= #need guikit.tmp run scoreboard players set #cost_fail guikit.tmp 1
$execute if score #cost_fail guikit.tmp matches 0 run scoreboard players operation @s $(cscore) -= #need guikit.tmp
