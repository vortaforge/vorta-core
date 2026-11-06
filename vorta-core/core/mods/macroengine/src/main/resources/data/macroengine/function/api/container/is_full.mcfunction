# macroengine:api/container/is_full
# Condition: is every slot of the container occupied?
# INPUT  macroengine:input x, y, z, size (int 1..256, optional: needed for modded or unknown blocks;
#        known vanilla containers report their own size)
# RETURN 1 when every slot has an item, else 0. macroengine:output container {ok}.
# "Full" means no free slot; a stack below its maximum count still counts as occupied.
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
data modify storage macroengine:output container.ok set value 1b
execute if score #ct_n macroengine.tmp >= #ct_size macroengine.tmp run return 1
return 0
