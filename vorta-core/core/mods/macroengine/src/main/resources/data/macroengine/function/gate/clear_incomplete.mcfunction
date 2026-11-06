# Gate 4 - operator clear: accepts the aborted load and runs the load again.
scoreboard players set #macroengine.loading vortaforge.gate 0
scoreboard players set #macroengine.incomplete vortaforge.gate 0
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a {"text":"[macroengine] Incomplete-load state cleared by an operator. Loading again.","color":"yellow"}
