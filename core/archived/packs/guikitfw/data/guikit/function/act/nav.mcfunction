# Remember previous page; only fire on_enter when the index changes
scoreboard players operation #prev_page guikit.tmp = @s guikit.page
execute if data storage guikit:act w.to store result score @s guikit.page run data get storage guikit:act w.to
execute if data storage guikit:act w.target_page store result score @s guikit.page run data get storage guikit:act w.target_page
execute unless score @s guikit.page = #prev_page guikit.tmp run function guikit:runtime/page_enter
