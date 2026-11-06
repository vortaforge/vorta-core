# Turns gate 1 off for rtwrapper. Takes effect on the next tick (gate 1 also at the next reload).
scoreboard players set #rtwrapper.gate.1 vortaforge.gate 0
function rtwrapper:gate/refresh
