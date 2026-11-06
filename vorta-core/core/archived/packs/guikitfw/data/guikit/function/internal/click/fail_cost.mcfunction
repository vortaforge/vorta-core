execute if data storage guikit:work cost_fail_msg run tellraw @s [{"text":"[guikit] ","color":"gold"},{"nbt":"cost_fail_msg","storage":"guikit:work","color":"red"}]
execute unless data storage guikit:work cost_fail_msg run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Not enough resources.","color":"red"}]
scoreboard players set @s guikit.click 2
