# Gate 2 - run as the player who typed /trigger rtwrapper.permit set 1.
scoreboard players set #rtwrapper.permit vortaforge.gate 1
function rtwrapper:gate/refresh
schedule function rtwrapper:gate/rerun_load 1t replace
tellraw @a [{"text":"[rtwrapper] Approved by ","color":"green"},{"selector":"@s"},{"text":". An operator can revoke with /function rtwrapper:gate/revoke","color":"gray"}]
scoreboard players reset @s rtwrapper.permit
