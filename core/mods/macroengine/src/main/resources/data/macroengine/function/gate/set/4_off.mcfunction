# Turns gate 4 off for macroengine. Takes effect on the next tick (also evaluated at the next reload).
scoreboard players set #macroengine.gate.4 vortaforge.gate 0
function macroengine:gate/refresh
