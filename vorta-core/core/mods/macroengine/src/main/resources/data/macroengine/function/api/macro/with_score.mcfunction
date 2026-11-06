# ─────────────────────────────────────────────
# macroengine:api/macro/with_score [MACRO]
#
# Reads a player's scoreboard value and injects it as a named
# macro variable into the target function.
#
# Usage:
#   function macroengine:api/macro/with_score \
#     {func:"ns:path", player:"Name", objective:"myObj", var:"myVar"}
#
# Parameters:
#   func      — function to call (ns:path)
#   player    — target player name
#   objective — scoreboard objective
#   var       — macro variable name to inject into the target function
#
# Output: $(myVar) → scoreboard value (int)
# ─────────────────────────────────────────────

# Write score into pipe under the requested variable name
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{macro:0b} run return 0
$execute store result storage macroengine:engine _macro_pipe.$(var) int 1 run scoreboard players get $(player) $(objective)

# Call target function with pipe as macro source
$function $(func) with storage macroengine:engine _macro_pipe

# Clear pipe
data remove storage macroengine:engine _macro_pipe
