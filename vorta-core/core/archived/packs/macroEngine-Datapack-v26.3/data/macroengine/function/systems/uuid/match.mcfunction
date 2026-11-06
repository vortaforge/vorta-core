# ============================================================
# macroengine:systems/uuid/match
# Compares @s entity's UUID with macroengine:input value
# If matched, runs macroengine:input func function
#
# USAGE:
# data modify storage macroengine:input value set value "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# data modify storage macroengine:input func set value "mynamespace:my_function"
# execute as <entity> run function macroengine:systems/uuid/match
#
# INPUT:
# macroengine:input value → UUID string to compare (expected)
# macroengine:input func → function to run if matched
#
# NOTE: func is run in the same entity context.
# ============================================================

# Save expected UUID string to temporary field
# (kept as a copy so the check below is independent of the input storage)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{uuid:0b} run return 0
data modify storage macroengine:uuid _match_target set from storage macroengine:input value

# Convert @s UUID to string → macroengine:output uuid
function macroengine:systems/uuid/from_entity

# Compare: if matched, run func
# Is the current UUID (macroengine:output uuid) equal to the expected?
function macroengine:core/internal/systems/uuid/match_check with storage macroengine:output
