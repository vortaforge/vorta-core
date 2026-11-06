execute unless data storage guikit:act w.functions[0] run return 0
data modify storage guikit:work fn set from storage guikit:act w.functions[0]
function guikit:act/_functions_one with storage guikit:work
data remove storage guikit:act w.functions[0]
function guikit:act/_functions
