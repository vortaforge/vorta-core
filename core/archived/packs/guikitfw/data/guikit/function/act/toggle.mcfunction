data remove storage guikit:work key
data modify storage guikit:work key set from storage guikit:act w.key
execute if data storage guikit:act w.toggle.score run data modify storage guikit:work key set from storage guikit:act w.toggle.score
execute unless data storage guikit:work key run return 0
function guikit:act/_toggle_flip with storage guikit:work
