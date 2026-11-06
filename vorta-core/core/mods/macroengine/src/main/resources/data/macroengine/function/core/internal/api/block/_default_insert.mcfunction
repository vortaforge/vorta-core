# macroengine:core/internal/api/block/_default_insert [INTERNAL]
# Default insert: the item goes into the first free slot (the slot used is written to macroengine:input slot).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input item.id run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_size_pick {src:"tmp.k",ovr:"size"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:container tmp.f set value {}
data modify storage macroengine:container tmp.f.x set from storage macroengine:container tmp.k.x
data modify storage macroengine:container tmp.f.y set from storage macroengine:container tmp.k.y
data modify storage macroengine:container tmp.f.z set from storage macroengine:container tmp.k.z
data modify storage macroengine:container tmp.f.i set value 0
scoreboard players set #ct_i macroengine.tmp 0
execute store result score #ct_ff macroengine.tmp run function macroengine:core/internal/api/container/_ff_loop with storage macroengine:container tmp.f
execute if score #ct_ff macroengine.tmp matches ..-1 run return 0
execute store result storage macroengine:input slot int 1 run scoreboard players get #ct_ff macroengine.tmp
return run function macroengine:core/internal/api/container/slot_set_do
