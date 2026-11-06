# Gate 2 - operator approve (same result as a player's /trigger, for servers that approve via function).
scoreboard players set #rtwrapper.permit vortaforge.gate 1
function rtwrapper:gate/refresh
schedule function rtwrapper:gate/rerun_load 1t replace
tellraw @a {"text":"[rtwrapper] Approved by an operator.","color":"green"}
