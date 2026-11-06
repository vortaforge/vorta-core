# Recomputes #macroengine.open: 1 only when every enabled gate passes. Every function of this pack
# starts with:  execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
# Gate 4 closes it after an unfinished load, gate 5 after a reload loop.
# Called from gate/version, permit grant/approve/revoke and the gate/set/* toggles.
scoreboard players set #macroengine.open vortaforge.gate 1
execute unless score #macroengine.gate.1 vortaforge.gate matches 0 unless score #macroengine.version vortaforge.gate matches 1 run scoreboard players set #macroengine.open vortaforge.gate 0
execute unless score #macroengine.gate.2 vortaforge.gate matches 0 unless score #macroengine.permit vortaforge.gate matches 1 run scoreboard players set #macroengine.open vortaforge.gate 0
execute unless score #macroengine.gate.4 vortaforge.gate matches 0 if score #macroengine.incomplete vortaforge.gate matches 1 run scoreboard players set #macroengine.open vortaforge.gate 0
execute unless score #macroengine.gate.5 vortaforge.gate matches 0 if score #macroengine.tripped vortaforge.gate matches 1 run scoreboard players set #macroengine.open vortaforge.gate 0
