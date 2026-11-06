# macroengine:core/internal/api/container/_move_m [INTERNAL, MACRO: x, y, z, slot, tx, ty, tz, dslot]
# Copies the stack with the engine's own item command, and clears the source only if the copy worked.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data block $(x) $(y) $(z) Items[{Slot:$(slot)b}] run return 0
$execute store success score #ct_ok macroengine.tmp run item replace block $(tx) $(ty) $(tz) container.$(dslot) from block $(x) $(y) $(z) container.$(slot)
$execute if score #ct_ok macroengine.tmp matches 1 run data remove block $(x) $(y) $(z) Items[{Slot:$(slot)b}]
return run scoreboard players get #ct_ok macroengine.tmp
