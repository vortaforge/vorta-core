# macroEngine player module — module marker (load step 1 of 3).
# macroEngine targets a single Minecraft version per pack, so instead of
# probing for installed library versions we simply pin the module marker
# that other parts of the pack may read from the 'load.status' objective.

scoreboard objectives add load.status dummy
scoreboard players set #player_action.major load.status 1
scoreboard players set #player_action.minor load.status 7
