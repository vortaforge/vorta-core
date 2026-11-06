data remove storage guikit:act w
data modify storage guikit:act w set value {}
# Prefer click id match against current page widgets in lib
data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute store result storage guikit:work page int 1 run scoreboard players get @s guikit.page
function guikit:internal/draw/load_page with storage guikit:work
data modify storage guikit:work queue set from storage guikit:draw widgets
data modify storage guikit:work want set from storage guikit:ctx click.id
execute unless data storage guikit:work want run data modify storage guikit:work want set from storage guikit:act click.id
function guikit:act/_resolve_loop
execute unless data storage guikit:act w.kind run data modify storage guikit:act w.kind set from storage guikit:ctx click.kind
