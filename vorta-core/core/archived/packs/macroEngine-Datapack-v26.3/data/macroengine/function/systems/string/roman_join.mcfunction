# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/roman_join [MACRO, internal]
# Joins the four Roman digit groups produced by string/roman.
#  Input : $(t), $(h), $(te), $(o)
# Output: macroengine:output result
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{string:0b} run return 0
$data modify storage macroengine:output result set value "$(t)$(h)$(te)$(o)"
