# macroEngine player module — cache the player's UUID into scores so other
# systems can compare identities via scoreboard logic.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score @s player_action.uuid.0 run data get entity @s UUID[0]
execute store result score @s player_action.uuid.1 run data get entity @s UUID[1]
execute store result score @s player_action.uuid.2 run data get entity @s UUID[2]
execute store result score @s player_action.uuid.3 run data get entity @s UUID[3]
