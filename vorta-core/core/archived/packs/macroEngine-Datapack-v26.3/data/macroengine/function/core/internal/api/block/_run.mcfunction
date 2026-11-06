# macroengine:core/internal/api/block/_run [INTERNAL]
# validate stage, then op stage. Sets macroengine:output block {ok, denied}.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output block set value {ok:0b,denied:0b}
execute unless function macroengine:core/internal/api/block/_validate_stage run data modify storage macroengine:output block.denied set value 1b
execute if data storage macroengine:output block{denied:1b} run return 0
execute unless function macroengine:core/internal/api/block/_op_stage run return 0
data modify storage macroengine:output block.ok set value 1b
return 1
