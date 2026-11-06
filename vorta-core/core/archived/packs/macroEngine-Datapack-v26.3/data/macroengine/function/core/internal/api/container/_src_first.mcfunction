# macroengine:core/internal/api/container/_src_first [INTERNAL, MACRO: x, y, z]
# Writes the slot of the first occupied entry to macroengine:container tmp.k.slot (nothing if empty).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data block $(x) $(y) $(z) Items[0] run return 0
$execute store result storage macroengine:container tmp.k.slot int 1 run data get block $(x) $(y) $(z) Items[0].Slot
return 1
