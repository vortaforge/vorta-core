# macro $(id) $(type)
$execute if score @s guikit.click matches 0 store success score @s guikit.click run clear @s *[custom_data~{guikit:{id:"$(id)"}}] 1
$execute if score @s guikit.click matches 1 run data modify storage guikit:ctx click set value {id:"$(id)",kind:"$(type)"}
execute if score @s guikit.click matches 1 run function guikit:internal/click/run_handler
