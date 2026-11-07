# macroengine:core/internal/api/container/_src_first [INTERNAL, MACRO: x, y, z]
# Writes the slot of the first occupied entry to macroengine:container tmp.k.slot (nothing if empty).
$execute unless data block $(x) $(y) $(z) Items[0] run return 0
$execute store result storage macroengine:container tmp.k.slot int 1 run data get block $(x) $(y) $(z) Items[0].Slot
return 1
