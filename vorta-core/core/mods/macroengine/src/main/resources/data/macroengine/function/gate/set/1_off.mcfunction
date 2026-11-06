# Turns gate 1 off for macroengine. Takes effect on the next tick (gate 1 also at the next reload).
scoreboard players set #macroengine.gate.1 vortaforge.gate 0
function macroengine:gate/refresh
