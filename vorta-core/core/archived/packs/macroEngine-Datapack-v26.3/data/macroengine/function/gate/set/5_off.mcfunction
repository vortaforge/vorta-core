# Turns gate 5 off for macroengine. Takes effect on the next tick (also evaluated at the next reload).
scoreboard players set #macroengine.gate.5 vortaforge.gate 0
function macroengine:gate/refresh
