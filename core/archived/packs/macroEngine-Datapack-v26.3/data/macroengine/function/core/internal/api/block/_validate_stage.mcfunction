# macroengine:core/internal/api/block/_validate_stage [INTERNAL]
# validate handler when registered, otherwise: the block must be a container. RETURN 1 allowed, 0 denied.
data modify storage macroengine:block tmp.m.h set value "validate"
execute store result score #bk_v macroengine.tmp run function macroengine:core/internal/api/block/_call with storage macroengine:block tmp.m
execute if score #bk_v macroengine.tmp matches 1.. run return 1
execute if score #bk_v macroengine.tmp matches 0 run return 0
return run function macroengine:core/internal/api/container/_exists with storage macroengine:container tmp.k
