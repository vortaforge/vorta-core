scoreboard players set #ok guikit.const 1
function guikit:internal/container/place_block
execute unless score @s guikit.mode matches 1 run scoreboard players set #ok guikit.const 0
