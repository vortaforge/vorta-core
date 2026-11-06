# macroengine:api/block/validate
# Asks whether an operation would be allowed, without doing it.
# INPUT  macroengine:input id, x, y, z, slot (optional), item (optional), op ("insert" default,
#        "take", "hopper_in", "hopper_out")
# OUTPUT macroengine:output block {ok, denied}   RETURN 1 allowed, 0 denied or refused.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{block:0b} run return 0
data modify storage macroengine:output block set value {ok:0b,denied:0b}
data modify storage macroengine:block tmp set value {m:{op:"insert"}}
execute if data storage macroengine:input {op:"take"} run data modify storage macroengine:block tmp.m.op set value "take"
execute if data storage macroengine:input {op:"hopper_in"} run data modify storage macroengine:block tmp.m.op set value "hopper_in"
execute if data storage macroengine:input {op:"hopper_out"} run data modify storage macroengine:block tmp.m.op set value "hopper_out"
execute unless function macroengine:core/internal/api/block/_prepare run return 0
execute unless function macroengine:core/internal/api/block/_validate_stage run data modify storage macroengine:output block.denied set value 1b
execute if data storage macroengine:output block{denied:1b} run return 0
data modify storage macroengine:output block.ok set value 1b
return 1
