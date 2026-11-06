execute unless data storage guikit:work rewards[0] run return 0
execute store result score #w guikit.tmp run data get storage guikit:work rewards[0].weight
execute unless score #w guikit.tmp matches 1.. run scoreboard players set #w guikit.tmp 1
execute if score #roll guikit.tmp < #w guikit.tmp run return run function guikit:act/_random_win
scoreboard players operation #roll guikit.tmp -= #w guikit.tmp
data remove storage guikit:work rewards[0]
function guikit:act/_random_pick
