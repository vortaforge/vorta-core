# Recomputes #rtwrapper.open: 1 only when every enabled gate passes. Every function of this pack
# starts with:  execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
# Called from gate/version, permit grant/approve/revoke and the gate/set/* toggles.
scoreboard players set #rtwrapper.open vortaforge.gate 1
execute unless score #rtwrapper.gate.1 vortaforge.gate matches 0 unless score #rtwrapper.version vortaforge.gate matches 1 run scoreboard players set #rtwrapper.open vortaforge.gate 0
execute unless score #rtwrapper.gate.2 vortaforge.gate matches 0 unless score #rtwrapper.permit vortaforge.gate matches 1 run scoreboard players set #rtwrapper.open vortaforge.gate 0
