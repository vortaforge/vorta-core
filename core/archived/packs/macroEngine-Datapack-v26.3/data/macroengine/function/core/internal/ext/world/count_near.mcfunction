# ======================================================================================
# macroengine:core/internal/ext/world/count_near [MACRO] [INTERNAL]
# $(type) validated as namespace:path, $(r) is an int clamped to 1..1024.
# ======================================================================================

$execute store result storage macroengine:output count int 1 if entity @e[type=$(type),distance=..$(r)]
