# Gate 2 - operator revoke: the pack goes inactive again until re-approved.
scoreboard players set #macroengine.permit vortaforge.gate 0
function macroengine:gate/refresh
tellraw @a {"text":"[macroengine] Approval revoked.","color":"yellow"}
function macroengine:gate/permit_prompt
