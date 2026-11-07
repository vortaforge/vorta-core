# macroengine:core/internal/api/container/_slot_get_m [INTERNAL, MACRO: x, y, z, slot]
$execute unless data block $(x) $(y) $(z) Items run return 0
data modify storage macroengine:output container.ok set value 1b
$execute if data block $(x) $(y) $(z) Items[{Slot:$(slot)b}] run data modify storage macroengine:output container.empty set value 0b
$data modify storage macroengine:output container.item set from block $(x) $(y) $(z) Items[{Slot:$(slot)b}]
return 1
