scoreboard players set #cd_block guikit.tmp 0
# per-widget cd score: guikit.cd is shared; use id hash via storage key in player data
# Simple global: if guikit.cd > 0 block (coarse). Prefer per-id later.
execute if score @s guikit.cd matches 1.. run scoreboard players set #cd_block guikit.tmp 1
execute if score #cd_block guikit.tmp matches 1 run tellraw @s [{"text":"[guikit] ","color":"gold"},{"text":"Cooldown.","color":"red"}]
execute if score #cd_block guikit.tmp matches 1 run scoreboard players set @s guikit.click 2
