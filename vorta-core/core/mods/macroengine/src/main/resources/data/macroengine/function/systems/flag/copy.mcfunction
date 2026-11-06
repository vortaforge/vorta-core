# ─────────────────────────────────────────────────────────────────
# macroengine:systems/flag/copy
# Copies a flag value from one key to another.
# If the source flag is set, the destination is set.
# If the source flag is absent, the destination is removed.
#  Input : $(from) → source flag key
#          $(to)   → destination flag key
# Output: macroengine:output result → 1b if copied (flag was set), 0b if cleared
#
# Example:
# data modify storage macroengine:input from set value "feature_a"
# data modify storage macroengine:input to set value "feature_a_backup"
# function macroengine:systems/flag/copy with storage macroengine:input {}
# ─────────────────────────────────────────────────────────────────

# Default: clear destination
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output result set value 0b

$execute if data storage macroengine:engine flags.$(from) run data modify storage macroengine:engine flags.$(to) set value 1b
$execute if data storage macroengine:engine flags.$(from) run data modify storage macroengine:output result set value 1b
$execute unless data storage macroengine:engine flags.$(from) run data remove storage macroengine:engine flags.$(to)
