execute unless data storage guikit:work scan[0] run return 0
data modify storage guikit:work w set from storage guikit:work scan[0]
data remove storage guikit:work scan[0]
# skip non-interactive
execute if data storage guikit:work w{kind:"separator"} run return run function guikit:internal/click/build_queue_loop
execute if data storage guikit:work w{kind:"label"} run return run function guikit:internal/click/build_queue_loop
execute if data storage guikit:work w{kind:"indicator"} run return run function guikit:internal/click/build_queue_loop
execute if data storage guikit:work w{kind:"progress"} run return run function guikit:internal/click/build_queue_loop
execute if data storage guikit:work w{clickable:0b} run return run function guikit:internal/click/build_queue_loop
# ensure id
execute unless data storage guikit:work w.id run data modify storage guikit:work w.id set from storage guikit:work w.kind
data modify storage guikit:work queue append from storage guikit:work w
function guikit:internal/click/build_queue_loop
