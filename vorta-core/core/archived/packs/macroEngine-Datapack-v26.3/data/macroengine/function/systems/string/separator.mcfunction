# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/separator
# Sends a decorative horizontal separator line.
#  Input : $(target) → selector
#          $(color)  → line color (e.g. "gray", "aqua", "#555555")
#          $(label)  → optional center label (use "" for plain line)
#
# Example (plain line):
# data modify storage macroengine:input target set value "@s"
# data modify storage macroengine:input color set value "gray"
# data modify storage macroengine:input label set value ""
# function macroengine:systems/string/separator with storage macroengine:input {}
#
# Example (labeled):
# data modify storage macroengine:input label set value " Settings "
# function macroengine:systems/string/separator with storage macroengine:input {}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$tellraw $(target) ["",{"text":"──────────","color":"$(color)"},{"text":"$(label)","color":"$(color)","bold":true},{"text":"──────────","color":"$(color)"}]
