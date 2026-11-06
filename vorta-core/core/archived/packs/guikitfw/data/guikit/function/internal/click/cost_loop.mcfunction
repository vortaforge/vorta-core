execute unless data storage guikit:work costs[0] run return 0
execute if score #cost_fail guikit.tmp matches 1 run return 0
# item cost
execute if data storage guikit:work costs[0].item run function guikit:internal/click/cost_item
# score cost
execute if data storage guikit:work costs[0].score run function guikit:internal/click/cost_score
data remove storage guikit:work costs[0]
execute if score #cost_fail guikit.tmp matches 0 run function guikit:internal/click/cost_loop
