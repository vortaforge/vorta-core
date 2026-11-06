data modify storage guikit:work key set from storage guikit:act w.cycle.score
execute unless data storage guikit:work key run data modify storage guikit:work key set from storage guikit:act w.key
execute unless data storage guikit:work key run return 0
execute store result score #max guikit.tmp run data get storage guikit:act w.cycle.options
scoreboard players remove #max guikit.tmp 1
execute if score #max guikit.tmp matches ..-1 run return 0
function guikit:act/_cycle_inc with storage guikit:work
execute if data storage guikit:act w.functions[0] run function guikit:act/_functions
