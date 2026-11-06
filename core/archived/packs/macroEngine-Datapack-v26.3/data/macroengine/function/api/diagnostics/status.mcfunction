# macroengine:api/diagnostics/status
# Machine-readable health check. Runs systems/diagnostics/collect and returns the number of issues
# (0 = healthy). Prints nothing. Full result: macroengine:output diagnostics (see docs/diagnostics.md).
# Read-only: it never enables a module, changes config or touches permissions.
#
# Usage:
#   execute store result score #x my.tmp run function macroengine:api/diagnostics/status
#   data get storage macroengine:output diagnostics.issues
#
# Caller: a player needs the macroengine.admin tag; a non-player caller (console, other datapack) is allowed.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.admin] run return 0

return run function macroengine:systems/diagnostics/collect
