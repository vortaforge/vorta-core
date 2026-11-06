# macroengine:core/internal/api/container/_count [INTERNAL, MACRO: x, y, z]
# Stores the number of occupied slots (length of Items) in #ct_n. RETURN 1 if readable, else 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set #ct_n macroengine.tmp 0
$execute unless data block $(x) $(y) $(z) Items run return 0
$execute store result score #ct_n macroengine.tmp run data get block $(x) $(y) $(z) Items
return 1
