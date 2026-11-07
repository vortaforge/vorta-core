# macroengine:core/internal/api/container/_slot_set_m [INTERNAL, MACRO: x, y, z, slot]
$execute unless data block $(x) $(y) $(z) Items run return 0
$data remove block $(x) $(y) $(z) Items[{Slot:$(slot)b}]
$execute store success score #ct_ok macroengine.tmp run data modify block $(x) $(y) $(z) Items append from storage macroengine:container tmp.item
execute if score #ct_ok macroengine.tmp matches 1 run data modify storage macroengine:output container.ok set value 1b
return run scoreboard players get #ct_ok macroengine.tmp
