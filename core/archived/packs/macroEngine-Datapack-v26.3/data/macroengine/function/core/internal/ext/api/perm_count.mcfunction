# ======================================================================================
# macroengine:core/internal/ext/api/perm_count [MACRO] [INTERNAL]
# $(player) has already been validated by api/perm/count.
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine permissions.$(player) store result storage macroengine:output result int 1 run data get storage macroengine:engine permissions.$(player)
