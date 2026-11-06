# macroengine:api/container/transfer
# Hopper-like transfer: moves ONE STACK from a source container to the first free slot of a target.
#
# INPUT  macroengine:input x, y, z (source), tx, ty, tz (target), slot (optional source slot,
#        default: first occupied slot), to_size (optional target size, for unknown blocks)
# OUTPUT macroengine:output container {ok, moved, from, to}
# RETURN 1 when a stack was moved, else 0 (nothing to move, target full, bad input).
# Whole stacks only: the stack is copied with the engine's own `item replace ... from block`, so
# stack limits are never exceeded. It does not merge into partly filled stacks.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
data modify storage macroengine:output container set value {ok:0b,moved:0b}
execute unless data storage macroengine:input tx run return 0
execute unless function macroengine:core/internal/api/container/_addr run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_exists with storage macroengine:container tmp.k
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:container tmp.d.x set from storage macroengine:container tmp.k.tx
data modify storage macroengine:container tmp.d.y set from storage macroengine:container tmp.k.ty
data modify storage macroengine:container tmp.d.z set from storage macroengine:container tmp.k.tz
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_exists with storage macroengine:container tmp.d
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:output container.ok set value 1b
execute unless data storage macroengine:container tmp.k.slot run function macroengine:core/internal/api/container/_src_first with storage macroengine:container tmp.k
execute unless data storage macroengine:container tmp.k.slot run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_size_pick {src:"tmp.d",ovr:"to_size"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:container tmp.f set from storage macroengine:container tmp.d
scoreboard players set #ct_i macroengine.tmp 0
data modify storage macroengine:container tmp.f.i set value 0
execute store result score #ct_ff macroengine.tmp run function macroengine:core/internal/api/container/_ff_loop with storage macroengine:container tmp.f
execute if score #ct_ff macroengine.tmp matches ..-1 run return 0
execute store result storage macroengine:container tmp.k.dslot int 1 run scoreboard players get #ct_ff macroengine.tmp
execute store result score #ct_mv macroengine.tmp run function macroengine:core/internal/api/container/_move_m with storage macroengine:container tmp.k
execute unless score #ct_mv macroengine.tmp matches 1 run return 0
data modify storage macroengine:output container.moved set value 1b
data modify storage macroengine:output container.from set from storage macroengine:container tmp.k.slot
data modify storage macroengine:output container.to set from storage macroengine:container tmp.k.dslot
return 1
