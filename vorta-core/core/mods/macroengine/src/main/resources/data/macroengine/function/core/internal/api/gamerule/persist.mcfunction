# macroengine:api/gamerule/internal/persist [MACRO]
# Writes the normalized rule name + value into macroengine:engine gamerules compound.
# Called exclusively by macroengine:api/gamerule/set — do NOT call directly.
#
# INPUT (macro args via `with storage macroengine:input {}`):
#   $(_gamerule_norm) — normalized rule name (spaces → underscores, lowercase)
#   $(value)          — value string

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine gamerules.$(_gamerule_norm) set value "$(value)"
