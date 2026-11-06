# macroengine:api/gamerule/internal/read [MACRO]
# Reads gamerule value from engine storage into output.
# Called by get only.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage macroengine:engine gamerules.$(_gamerule_norm) run data modify storage macroengine:output gamerule set from storage macroengine:engine gamerules.$(_gamerule_norm)
