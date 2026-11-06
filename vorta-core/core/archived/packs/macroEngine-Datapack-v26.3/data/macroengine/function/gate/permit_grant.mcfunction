# Gate 2 - run as the player who typed /trigger macroengine.permit set 1.
# Only that player gets the consent screen (gate/consent_route); everybody else gets a chat notice.
scoreboard players set #macroengine.permit vortaforge.gate 1
function macroengine:gate/consent_route
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a [{"text":"[macroengine] Approved by ","color":"green"},{"selector":"@s"},{"text":". An operator can revoke with /function macroengine:gate/revoke","color":"gray"}]
scoreboard players reset @s macroengine.permit
