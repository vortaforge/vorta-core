# macroengine:api/container/slot_swap
# Swaps two slots of one container. An empty slot swaps too (the item moves).
# INPUT  macroengine:input x, y, z, slot, slot2
# OUTPUT macroengine:output container {ok}
# RETURN 1 on success, 0 on bad input or a block without an inventory.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
data modify storage macroengine:output container set value {ok:0b}
execute unless data storage macroengine:input slot run return 0
execute unless data storage macroengine:input slot2 run return 0
execute unless function macroengine:core/internal/api/container/_addr run return 0
execute store result score #ct_a macroengine.tmp run data get storage macroengine:container tmp.k.slot
execute store result score #ct_b macroengine.tmp run data get storage macroengine:container tmp.k.slot2
execute if score #ct_a macroengine.tmp = #ct_b macroengine.tmp run return run function macroengine:core/internal/api/container/_exists with storage macroengine:container tmp.k
return run function macroengine:core/internal/api/container/_swap_m with storage macroengine:container tmp.k
