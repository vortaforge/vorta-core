# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/from_input
# Execute a simple command list (backward compatible)
#
# INPUT (storage macroengine:input):
# list → command list ["cmd1", "cmd2", ...]
#
# EXAMPLE:
# data modify storage macroengine:input list set value ["say Hello", "say World"]
# function macroengine:api/cmd/other/multi_cmd/from_input
# ─────────────────────────────────────────────────────────────────

# Copy list to queue
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.from_input"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
data modify storage macroengine:engine _mcmd_queue set from storage macroengine:input list

# Set default options
data modify storage macroengine:engine _mcmd_options set value {error_mode:"continue",profile:0b,spread:0}

# Execute
function macroengine:api/cmd/other/multi_cmd/run