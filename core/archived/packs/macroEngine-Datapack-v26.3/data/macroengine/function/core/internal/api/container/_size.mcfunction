# macroengine:core/internal/api/container/_size [INTERNAL, MACRO: x, y, z]
# Slot count of the vanilla container at the position. RETURN 0 when unknown.
# Double chests report the size of one half (each half is its own block entity).
$execute if block $(x) $(y) $(z) #minecraft:shulker_boxes run return 27
$execute if block $(x) $(y) $(z) minecraft:chest run return 27
$execute if block $(x) $(y) $(z) minecraft:trapped_chest run return 27
$execute if block $(x) $(y) $(z) minecraft:barrel run return 27
$execute if block $(x) $(y) $(z) minecraft:hopper run return 5
$execute if block $(x) $(y) $(z) minecraft:brewing_stand run return 5
$execute if block $(x) $(y) $(z) minecraft:furnace run return 3
$execute if block $(x) $(y) $(z) minecraft:smoker run return 3
$execute if block $(x) $(y) $(z) minecraft:blast_furnace run return 3
$execute if block $(x) $(y) $(z) minecraft:dispenser run return 9
$execute if block $(x) $(y) $(z) minecraft:dropper run return 9
$execute if block $(x) $(y) $(z) minecraft:crafter run return 9
return 0
