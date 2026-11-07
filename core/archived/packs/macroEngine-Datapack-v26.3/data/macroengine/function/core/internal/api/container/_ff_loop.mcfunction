# macroengine:core/internal/api/container/_ff_loop [INTERNAL, MACRO: x, y, z, i]
# First slot below #ct_size without an item, searching from i. RETURN the slot, or -1 when full.
$execute unless data block $(x) $(y) $(z) Items[{Slot:$(i)b}] run return $(i)
scoreboard players add #ct_i macroengine.tmp 1
execute if score #ct_i macroengine.tmp >= #ct_size macroengine.tmp run return -1
execute store result storage macroengine:container tmp.f.i int 1 run scoreboard players get #ct_i macroengine.tmp
return run function macroengine:core/internal/api/container/_ff_loop with storage macroengine:container tmp.f
