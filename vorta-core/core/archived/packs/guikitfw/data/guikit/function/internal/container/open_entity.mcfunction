scoreboard players set @s guikit.mode 0
function guikit:internal/container/kill_mine
function guikit:internal/container/summon
execute unless entity @e[type=#guikit:container,tag=guikit.new,limit=1] run return run function guikit:internal/open/fail
scoreboard players operation @e[type=#guikit:container,tag=guikit.new,limit=1] guikit.pid = @s guikit.pid
scoreboard players operation @e[type=#guikit:container,tag=guikit.new,limit=1] guikit.uid = @s guikit.uid
tag @e[type=#guikit:container,tag=guikit.new] remove guikit.new
scoreboard players set #ok guikit.const 1
