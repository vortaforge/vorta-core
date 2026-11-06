# Turns gate 2 off for rtwrapper. Takes effect on the next tick (gate 1 also at the next reload).
scoreboard players set #rtwrapper.gate.2 vortaforge.gate 0
function rtwrapper:gate/refresh
