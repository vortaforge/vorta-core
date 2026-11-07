# macroengine:core/internal/api/block/_run [INTERNAL]
# validate stage, then op stage. Sets macroengine:output block {ok, denied}.
data modify storage macroengine:output block set value {ok:0b,denied:0b}
execute unless function macroengine:core/internal/api/block/_validate_stage run data modify storage macroengine:output block.denied set value 1b
execute if data storage macroengine:output block{denied:1b} run return 0
execute unless function macroengine:core/internal/api/block/_op_stage run return 0
data modify storage macroengine:output block.ok set value 1b
return 1
