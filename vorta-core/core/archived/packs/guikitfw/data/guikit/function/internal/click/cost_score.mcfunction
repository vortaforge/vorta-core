data modify storage guikit:work cscore set from storage guikit:work costs[0].score
execute store result score #need guikit.tmp run data get storage guikit:work costs[0].amount
function guikit:internal/click/cost_score_do with storage guikit:work
