execute unless data storage guikit:work det[0] run return 0
data modify storage guikit:work want set value "left"
data modify storage guikit:work got set from storage guikit:work det[0]
data modify storage guikit:work test set from storage guikit:work want
execute store success score #d guikit.tmp run data modify storage guikit:work test set from storage guikit:work got
execute if score #d guikit.tmp matches 0 run return run function guikit:internal/click/left_do
data remove storage guikit:work det[0]
function guikit:internal/click/maybe_left_scan
