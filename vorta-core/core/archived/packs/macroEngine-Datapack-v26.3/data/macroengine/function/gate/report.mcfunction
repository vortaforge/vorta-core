# ======================================================================================
# macroengine:gate/report
# Machine-readable version of gate/status: copies the gate scores to storage instead of
# printing them.
#
# OUTPUT macroengine:output gate  (all ints; a missing score reads as 0)
#   open, version_ok, permit, installed, expected, incomplete, tripped,
#   gate_1 .. gate_5   (1 = that gate is on, 0 = off)
# RETURN the value of 'open' (1 or 0).
#
# Deliberately has NO gate guard (see gate/is_open). Read-only.
#
# Usage:
#   function macroengine:gate/report
#   data get storage macroengine:output gate.open
# ======================================================================================

data modify storage macroengine:output gate set value {open:0,version_ok:0,permit:0,installed:0,expected:0,incomplete:0,tripped:0,gate_1:0,gate_2:0,gate_3:0,gate_4:0,gate_5:0}
execute store result storage macroengine:output gate.open int 1 run scoreboard players get #macroengine.open vortaforge.gate
execute store result storage macroengine:output gate.version_ok int 1 run scoreboard players get #macroengine.version vortaforge.gate
execute store result storage macroengine:output gate.permit int 1 run scoreboard players get #macroengine.permit vortaforge.gate
execute store result storage macroengine:output gate.installed int 1 run scoreboard players get #macroengine.installed vortaforge.gate
execute store result storage macroengine:output gate.expected int 1 run scoreboard players get #macroengine.expected vortaforge.gate
execute store result storage macroengine:output gate.incomplete int 1 run scoreboard players get #macroengine.incomplete vortaforge.gate
execute store result storage macroengine:output gate.tripped int 1 run scoreboard players get #macroengine.tripped vortaforge.gate
execute store result storage macroengine:output gate.gate_1 int 1 run scoreboard players get #macroengine.gate.1 vortaforge.gate
execute store result storage macroengine:output gate.gate_2 int 1 run scoreboard players get #macroengine.gate.2 vortaforge.gate
execute store result storage macroengine:output gate.gate_3 int 1 run scoreboard players get #macroengine.gate.3 vortaforge.gate
execute store result storage macroengine:output gate.gate_4 int 1 run scoreboard players get #macroengine.gate.4 vortaforge.gate
execute store result storage macroengine:output gate.gate_5 int 1 run scoreboard players get #macroengine.gate.5 vortaforge.gate
execute if score #macroengine.open vortaforge.gate matches 1 run return 1
return 0
