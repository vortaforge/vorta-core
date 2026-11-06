# Run pages[page].on_enter function list if present
data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:runtime/page_enter_load with storage guikit:work
execute if data storage guikit:work on_enter[0] run data modify storage guikit:act w.functions set from storage guikit:work on_enter
execute if data storage guikit:act w.functions[0] run function guikit:act/_functions
