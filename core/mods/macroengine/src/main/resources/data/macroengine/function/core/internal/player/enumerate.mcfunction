# macroEngine player module — module marker (load step 1 of 3).
# macroEngine targets a single Minecraft version per pack, so instead of
# probing for installed library versions we simply pin the module marker
# that other parts of the pack may read from the 'load.status' objective.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard objectives add load.status dummy
scoreboard players set #player_action.major load.status 1
scoreboard players set #player_action.minor load.status 7
