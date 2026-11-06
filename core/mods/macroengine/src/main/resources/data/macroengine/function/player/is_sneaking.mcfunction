# ─────────────────────────────────────────────────────────────────
# macroengine:player/is_sneaking
# Checks whether a named player is currently sneaking.
# Uses the macroengine:is_sneaking predicate (entity_flags).
#
# INPUT : $(player) → player name
# OUTPUT: macroengine:output result → 1b if sneaking, 0b otherwise
# macroengine:output found → 1b if player online, 0b otherwise
#
# EXAMPLE:
# function macroengine:player/is_sneaking {player:"Steve"}
# → macroengine:output result = 1b
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output found set value 0b
data modify storage macroengine:output result set value 0b

$execute unless entity @a[name=$(player),limit=1] run return 0

data modify storage macroengine:output found set value 1b
$execute as @a[name=$(player),limit=1] if predicate macroengine:is_sneaking run data modify storage macroengine:output result set value 1b
