# Gates 4 and 5 - evaluated on every load. Called from gate/version, before gate/refresh.
# Gate 4 (incomplete-load gate): #macroengine.loading is set to 1 by gate/load_begin and back to 0 by
#   gate/load_end at the end of macroengine:setup. If it is still 1 now, the previous load never reached
#   the end of setup (for example a function chain was cut off), so the pack may be half-initialised.
#   This detects an aborted setup only; it cannot see a single failing command inside a finished setup.
# Gate 5 (reload-loop gate): counts loads inside a window. gate/loads_decay clears the count 1200t after
#   the last load. 6 or more loads inside that window trip the gate until an operator clears it.
# Toggles: function macroengine:gate/set/4_off | 4_on | 5_off | 5_on. Default: on.
# Safeguard, not a sandbox: a datapack is plain text and the checks can be deleted.
execute unless score #macroengine.loading vortaforge.gate = #macroengine.loading vortaforge.gate run scoreboard players set #macroengine.loading vortaforge.gate 0
execute unless score #macroengine.loads vortaforge.gate = #macroengine.loads vortaforge.gate run scoreboard players set #macroengine.loads vortaforge.gate 0
execute unless score #macroengine.tripped vortaforge.gate = #macroengine.tripped vortaforge.gate run scoreboard players set #macroengine.tripped vortaforge.gate 0
scoreboard players set #macroengine.incomplete vortaforge.gate 0
execute if score #macroengine.loading vortaforge.gate matches 1 run scoreboard players set #macroengine.incomplete vortaforge.gate 1
scoreboard players add #macroengine.loads vortaforge.gate 1
schedule function macroengine:gate/loads_decay 1200t replace
execute if score #macroengine.loads vortaforge.gate matches 6.. run scoreboard players set #macroengine.tripped vortaforge.gate 1
execute unless score #macroengine.gate.4 vortaforge.gate matches 0 if score #macroengine.incomplete vortaforge.gate matches 1 run tellraw @a {"text":"[macroengine] The previous load did not finish. macroengine stays inactive (incomplete-load gate). Check the server log, then run /function macroengine:gate/clear_incomplete","color":"red"}
execute unless score #macroengine.gate.5 vortaforge.gate matches 0 if score #macroengine.tripped vortaforge.gate matches 1 run tellraw @a {"text":"[macroengine] Too many loads in a short time. macroengine stays inactive (reload-loop gate). Find what keeps reloading, then run /function macroengine:gate/clear_tripped","color":"red"}
