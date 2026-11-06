# macroengine:api/container/is_empty
# Condition: does the container hold no items at all?
# INPUT  macroengine:input x, y, z
# RETURN 1 when it is a container with no items, else 0. macroengine:output container {ok}.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{container:0b} run return 0
data modify storage macroengine:output container set value {ok:0b}
execute unless function macroengine:core/internal/api/container/_addr run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/container/_count with storage macroengine:container tmp.k
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:output container.ok set value 1b
execute if score #ct_n macroengine.tmp matches 0 run return 1
return 0
