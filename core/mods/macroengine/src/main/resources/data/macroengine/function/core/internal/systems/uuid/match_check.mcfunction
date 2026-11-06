# ============================================================
# macroengine:systems/uuid/internal/match_check [MACRO FUNCTION]
# Dynamically compares the current UUID string with _match_target
#
# Call: function macroengine:core/internal/systems/uuid/match_check with storage macroengine:output
# $(uuid) = current UUID string written by from_entity
# ============================================================
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:uuid {_match_target:"$(uuid)"} run function macroengine:core/internal/systems/uuid/match_fire with storage macroengine:input
