# macroengine:core/internal/api/gamerule/normalize  [INTERNAL]
# Normalizes the rule name in macroengine:input rule: spaces become underscores, then ASCII
# lowercase. Result goes to macroengine:input _gamerule_norm. If the name contains a double
# quote or a backslash it is left unset, so the macro calls that follow fail instead of
# running with an unsafe value.
function macroengine:core/internal/api/gamerule/normalize_run
function macroengine:core/internal/text/reset
