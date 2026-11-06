# Tag this player's container as guikit.me
tag @e[type=#guikit:container,tag=guikit.cart] remove guikit.me
scoreboard players operation #pid guikit.tmp = @s guikit.pid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.pid = #pid guikit.tmp run tag @s add guikit.me
