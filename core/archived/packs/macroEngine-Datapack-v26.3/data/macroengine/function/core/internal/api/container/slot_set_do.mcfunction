# macroengine:core/internal/api/container/slot_set_do [INTERNAL]
# Body of api/container/slot_set (no module gate, so api/block can reuse it).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output container set value {ok:0b}
execute unless data storage macroengine:input item.id run return 0
execute unless data storage macroengine:input slot run return 0
execute unless function macroengine:core/internal/api/container/_addr run return 0
data modify storage macroengine:container tmp.item set from storage macroengine:input item
execute unless data storage macroengine:container tmp.item.count run data modify storage macroengine:container tmp.item.count set value 1
execute store result score #ct_c macroengine.tmp run data get storage macroengine:container tmp.item.count
execute unless score #ct_c macroengine.tmp matches 1..99 run return 0
execute store result storage macroengine:container tmp.item.count int 1 run scoreboard players get #ct_c macroengine.tmp
execute store result storage macroengine:container tmp.item.Slot byte 1 run data get storage macroengine:container tmp.k.slot
return run function macroengine:core/internal/api/container/_slot_set_m with storage macroengine:container tmp.k
