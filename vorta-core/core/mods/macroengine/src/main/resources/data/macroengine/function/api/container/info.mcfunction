# macroengine:api/container/info
# One-call summary of a container block: size, used and free slots, first free slot.
# INPUT  macroengine:input x, y, z, size (int 1..256, optional: needed for modded or unknown blocks;
#        known vanilla containers report their own size)
# OUTPUT macroengine:output container {ok:1b, size, used, free, empty:1b/0b, full:1b/0b, first_free}
#        first_free is the lowest slot without an item, or -1 when the container is full.
#        "used" counts occupied slots (not items); a partly filled stack still counts as used.
# RETURN 1 when the block is a container and its size is known, else 0 (container {ok:0b}).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
data modify storage macroengine:output container set value {ok:0b}
execute unless function macroengine:core/internal/api/container/_addr run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_count with storage macroengine:container tmp.k
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_size_pick {src:"tmp.k",ovr:"size"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0

scoreboard players operation #ct_free macroengine.tmp = #ct_size macroengine.tmp
scoreboard players operation #ct_free macroengine.tmp -= #ct_n macroengine.tmp
execute if score #ct_free macroengine.tmp matches ..-1 run scoreboard players set #ct_free macroengine.tmp 0

data modify storage macroengine:output container.ok set value 1b
execute store result storage macroengine:output container.size int 1 run scoreboard players get #ct_size macroengine.tmp
execute store result storage macroengine:output container.used int 1 run scoreboard players get #ct_n macroengine.tmp
execute store result storage macroengine:output container.free int 1 run scoreboard players get #ct_free macroengine.tmp
data modify storage macroengine:output container.empty set value 0b
data modify storage macroengine:output container.full set value 0b
data modify storage macroengine:output container.first_free set value -1
execute if score #ct_n macroengine.tmp matches 0 run data modify storage macroengine:output container.empty set value 1b
execute if score #ct_free macroengine.tmp matches 0 run data modify storage macroengine:output container.full set value 1b
execute if score #ct_free macroengine.tmp matches 0 run return 1

# Not full: find the lowest free slot (same loop as api/container/transfer)
data modify storage macroengine:container tmp.f set from storage macroengine:container tmp.k
data modify storage macroengine:container tmp.f.i set value 0
scoreboard players set #ct_i macroengine.tmp 0
execute store result score #ct_ff macroengine.tmp run function macroengine:core/internal/api/container/_ff_loop with storage macroengine:container tmp.f
execute store result storage macroengine:output container.first_free int 1 run scoreboard players get #ct_ff macroengine.tmp
return 1
