# ======================================================================================
# macroengine:core/internal/ext/world/count_near [MACRO] [INTERNAL]
# $(type) validated as namespace:path, $(r) is an int clamped to 1..1024.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute store result storage macroengine:output count int 1 if entity @e[type=$(type),distance=..$(r)]
