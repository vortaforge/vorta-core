# ─────────────────────────────────────────────────────────────────
# macroengine:systems/string/roman_join [MACRO, internal]
# Joins the four Roman digit groups produced by string/roman.
#  Input : $(t), $(h), $(te), $(o)
# Output: macroengine:output result
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{string:0b} run return 0
$data modify storage macroengine:output result set value "$(t)$(h)$(te)$(o)"
