# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/percent [MACRO]
# Formats a number as a percent string.
#  Input : $(value)
# Output: macroengine:output result → "<value>%"
#
# Example: function macroengine:systems/string/percent {value:75}  → "75%"
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$data modify storage macroengine:output result set value "$(value)%"
