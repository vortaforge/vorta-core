# macroengine:api/gamerule/internal/remove [MACRO]
# Removes a single gamerule key from engine storage.
# Called by reset only.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine gamerules.$(_gamerule_norm)
