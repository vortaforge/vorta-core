# macroEngine player module — zero every event counter after dispatch so
# each statistic fires at most once per tick.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set @s player_action.fly 0
scoreboard players set @s player_action.walk 0
scoreboard players set @s player_action.fall 0
scoreboard players set @s player_action.climb 0
scoreboard players set @s player_action.aviate 0

scoreboard players set @s player_action.death 0
scoreboard players set @s player_action.enchant 0
scoreboard players set @s player_action.jump 0
scoreboard players set @s player_action.use_coas 0
scoreboard players set @s player_action.use_wfoas 0
scoreboard players set @s player_action.join 0
