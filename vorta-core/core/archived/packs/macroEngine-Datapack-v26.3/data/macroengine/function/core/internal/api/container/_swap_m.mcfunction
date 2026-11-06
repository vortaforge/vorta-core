# macroengine:core/internal/api/container/_swap_m [INTERNAL, MACRO: x, y, z, slot, slot2]
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data block $(x) $(y) $(z) Items run return 0
data remove storage macroengine:container tmp.a
data remove storage macroengine:container tmp.b
$data modify storage macroengine:container tmp.a set from block $(x) $(y) $(z) Items[{Slot:$(slot)b}]
$data modify storage macroengine:container tmp.b set from block $(x) $(y) $(z) Items[{Slot:$(slot2)b}]
$data remove block $(x) $(y) $(z) Items[{Slot:$(slot)b}]
$data remove block $(x) $(y) $(z) Items[{Slot:$(slot2)b}]
execute if data storage macroengine:container tmp.a store result storage macroengine:container tmp.a.Slot byte 1 run data get storage macroengine:container tmp.k.slot2
execute if data storage macroengine:container tmp.b store result storage macroengine:container tmp.b.Slot byte 1 run data get storage macroengine:container tmp.k.slot
$execute if data storage macroengine:container tmp.a run data modify block $(x) $(y) $(z) Items append from storage macroengine:container tmp.a
$execute if data storage macroengine:container tmp.b run data modify block $(x) $(y) $(z) Items append from storage macroengine:container tmp.b
data modify storage macroengine:output container.ok set value 1b
return 1
