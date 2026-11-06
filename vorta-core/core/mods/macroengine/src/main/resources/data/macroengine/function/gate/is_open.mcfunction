# ======================================================================================
# macroengine:gate/is_open
# Tells another datapack whether macroEngine is currently usable, without printing anything.
# RETURN 1 when the gate is open (#macroengine.open = 1), 0 otherwise.
#
# Deliberately has NO gate guard: its whole job is to answer while the pack is closed.
# It reads one score and changes nothing.
#
# Usage:
#   execute if function macroengine:gate/is_open run function mypack:use_macroengine
# ======================================================================================

execute if score #macroengine.open vortaforge.gate matches 1 run return 1
return 0
