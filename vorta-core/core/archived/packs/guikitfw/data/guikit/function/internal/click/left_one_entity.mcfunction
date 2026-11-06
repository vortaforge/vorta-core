# macro $(id) $(type) $(slot)
$execute if score @s guikit.click matches 0 unless items entity @e[type=#guikit:container,tag=guikit.me,limit=1] container.$(slot) *[custom_data~{guikit:{id:"$(id)"}}] run data modify storage guikit:ctx click set value {id:"$(id)",kind:"$(type)"}
$execute if score @s guikit.click matches 0 if data storage guikit:ctx click{id:"$(id)"} run scoreboard players set @s guikit.click 1
execute if score @s guikit.click matches 1 run function guikit:internal/click/run_handler
