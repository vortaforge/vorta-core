# Gate 2 - operator approve (same result as a player's /trigger, for servers that approve via function).
# "execute as <player> run function macroengine:gate/approve" opens the consent screen for that player only;
# from the console or a command block nobody gets a screen, everybody is told in chat.
scoreboard players set #macroengine.permit vortaforge.gate 1
function macroengine:gate/consent_route
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a {"text":"[macroengine] Approved by an operator.","color":"green"}
