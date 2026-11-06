# ─────────────────────────────────────────────────────────────────
# macroengine:systems/flag/get_or_default
# Returns 1b if the flag is set, otherwise stores the given default.
#  Input : $(key)     → flag key
#          $(default) → value to store if flag is absent (0b or 1b)
#  Output: macroengine:output result → 1b if set, $(default) if absent
#
# Example:
# data modify storage macroengine:input key set value "my_feature"
# data modify storage macroengine:input default set value 0b
# function macroengine:systems/flag/get_or_default with storage macroengine:input {}
# macroengine:output result = 0b (if flag not set)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:output result set value $(default)
$execute if data storage macroengine:engine flags.$(key) run data modify storage macroengine:output result set value 1b
