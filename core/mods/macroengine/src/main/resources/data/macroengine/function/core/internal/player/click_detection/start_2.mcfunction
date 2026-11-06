
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation @s player_action.uuid.0 = #uuid.0 player_action.data
scoreboard players operation @s player_action.uuid.1 = #uuid.1 player_action.data
scoreboard players operation @s player_action.uuid.2 = #uuid.2 player_action.data
scoreboard players operation @s player_action.uuid.3 = #uuid.3 player_action.data

tag @s remove player_action.new
