# macroengine:core/internal/api/block/_prepare [INTERNAL]
# Shared first step of insert / take / hopper_in / hopper_out / validate.
# Checks the block id (safe_name), the position and slot (as numbers), that the id is registered,
# and builds the handler context macroengine:block ctx. RETURN 1 ready, 0 refused.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input id
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:block tmp.m.id set from storage macroengine:input id
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_registered with storage macroengine:block tmp.m
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
execute unless function macroengine:core/internal/api/container/_addr run return 0
data modify storage macroengine:block ctx set value {}
data modify storage macroengine:block ctx.op set from storage macroengine:block tmp.m.op
data modify storage macroengine:block ctx.x set from storage macroengine:container tmp.k.x
data modify storage macroengine:block ctx.y set from storage macroengine:container tmp.k.y
data modify storage macroengine:block ctx.z set from storage macroengine:container tmp.k.z
data modify storage macroengine:block tmp.p set from storage macroengine:block ctx
execute if data storage macroengine:container tmp.k.slot run data modify storage macroengine:block ctx.slot set from storage macroengine:container tmp.k.slot
execute if data storage macroengine:input item run data modify storage macroengine:block ctx.item set from storage macroengine:input item
return 1
