execute unless data storage guikit:work queue[0] run return 0
data remove storage guikit:work cur
data modify storage guikit:work cur set from storage guikit:work queue[0].id
execute unless data storage guikit:work cur run data modify storage guikit:work cur set from storage guikit:work queue[0].kind
data remove storage guikit:work test
data modify storage guikit:work test set from storage guikit:work want
execute store success score #diff guikit.tmp run data modify storage guikit:work test set from storage guikit:work cur
execute if score #diff guikit.tmp matches 0 run data modify storage guikit:act w set from storage guikit:work queue[0]
execute if score #diff guikit.tmp matches 0 run return 0
data remove storage guikit:work queue[0]
function guikit:act/_resolve_loop
