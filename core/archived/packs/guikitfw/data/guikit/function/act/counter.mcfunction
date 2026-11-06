data remove storage guikit:work key
data modify storage guikit:work key set from storage guikit:act w.key
execute if data storage guikit:act w.counter_score run data modify storage guikit:work key set from storage guikit:act w.counter_score
execute unless data storage guikit:work key run return 0
execute store result score #delta guikit.tmp run data get storage guikit:act w.delta
execute if data storage guikit:act w.counter_delta store result score #delta guikit.tmp run data get storage guikit:act w.counter_delta
execute unless score #delta guikit.tmp matches 1.. run scoreboard players set #delta guikit.tmp 1
execute store result score #min guikit.tmp run data get storage guikit:act w.min
execute store result score #max guikit.tmp run data get storage guikit:act w.max
execute if data storage guikit:act w.counter_min store result score #min guikit.tmp run data get storage guikit:act w.counter_min
execute if data storage guikit:act w.counter_max store result score #max guikit.tmp run data get storage guikit:act w.counter_max
execute unless score #max guikit.tmp matches 1.. run scoreboard players set #max guikit.tmp 64
function guikit:act/_counter_add with storage guikit:work
