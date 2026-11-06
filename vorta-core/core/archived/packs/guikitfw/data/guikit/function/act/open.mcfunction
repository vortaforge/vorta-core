data remove storage guikit:in menu
data modify storage guikit:in menu set from storage guikit:act w.menu
execute if data storage guikit:act w.to run data modify storage guikit:in menu set from storage guikit:act w.to
execute unless data storage guikit:in menu run return 0
function guikit:api/open
