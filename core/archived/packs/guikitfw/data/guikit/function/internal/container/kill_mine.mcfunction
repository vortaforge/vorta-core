scoreboard players operation #pid guikit.tmp = @s guikit.pid
execute as @e[type=#guikit:container,tag=guikit.cart] if score @s guikit.pid = #pid guikit.tmp run kill @s
