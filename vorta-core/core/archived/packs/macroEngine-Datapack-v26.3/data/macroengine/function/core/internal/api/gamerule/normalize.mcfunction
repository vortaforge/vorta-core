# macroengine:core/internal/api/gamerule/normalize  [INTERNAL]
# Normalizes the rule name in macroengine:input rule: spaces become underscores, then ASCII
# lowercase. Result goes to macroengine:input _gamerule_norm. If the name contains a double
# quote or a backslash it is left unset, so the macro calls that follow fail instead of
# running with an unsafe value.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/gamerule/normalize_run
function macroengine:core/internal/text/reset
