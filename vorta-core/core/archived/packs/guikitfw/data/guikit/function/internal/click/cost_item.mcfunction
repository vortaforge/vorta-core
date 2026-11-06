data modify storage guikit:work citem set from storage guikit:work costs[0].item
execute store result storage guikit:work ccount int 1 run data get storage guikit:work costs[0].count
execute unless data storage guikit:work ccount run data modify storage guikit:work ccount set value 1
function guikit:internal/click/cost_item_do with storage guikit:work
