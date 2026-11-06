# Gate 5 - operator clear: resets the load count and the tripped state and runs the load again.
scoreboard players set #macroengine.loads vortaforge.gate 0
scoreboard players set #macroengine.tripped vortaforge.gate 0
function macroengine:gate/refresh
schedule function macroengine:gate/rerun_load 1t replace
tellraw @a {"text":"[macroengine] Reload-loop gate cleared by an operator. Loading again.","color":"yellow"}
