execute unless data storage guikit:act w.random.rewards[0] run return 0
scoreboard players set #sum guikit.tmp 0
data modify storage guikit:work rewards set from storage guikit:act w.random.rewards
function guikit:act/_random_sum
execute if score #sum guikit.tmp matches ..0 run return 0
execute store result score #roll guikit.tmp run random value 0..2147483646
scoreboard players operation #roll guikit.tmp %= #sum guikit.tmp
data modify storage guikit:work rewards set from storage guikit:act w.random.rewards
function guikit:act/_random_pick
