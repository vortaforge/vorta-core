data modify storage guikit:work id set from storage guikit:ctx menu
function guikit:internal/draw/load_menu with storage guikit:work
execute unless data storage guikit:draw menu.on_close[0] run return 0
data modify storage guikit:act w.functions set from storage guikit:draw menu.on_close
function guikit:act/_functions
