# ======================================================================================
# macroengine:core/internal/ext/api/perm_count [MACRO] [INTERNAL]
# $(player) has already been validated by api/perm/count.
# ======================================================================================

$execute if data storage macroengine:engine permissions.$(player) store result storage macroengine:output result int 1 run data get storage macroengine:engine permissions.$(player)
