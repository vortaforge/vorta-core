# macroengine:core/internal/api/block/_op_stage [INTERNAL]
# Runs the handler named like the op (insert, take, hopper_in, hopper_out); with no handler the
# default container behaviour runs. RETURN 1 success, 0 failure.
data modify storage macroengine:block tmp.m.h set from storage macroengine:block tmp.m.op
execute store result score #bk_r macroengine.tmp run function macroengine:core/internal/api/block/_call with storage macroengine:block tmp.m
execute if score #bk_r macroengine.tmp matches 1.. run return 1
execute if score #bk_r macroengine.tmp matches 0 run return 0
execute if data storage macroengine:block tmp.m{op:"insert"} run return run function macroengine:core/internal/api/block/_default_insert
execute if data storage macroengine:block tmp.m{op:"hopper_in"} run return run function macroengine:core/internal/api/block/_default_insert
return run function macroengine:core/internal/api/block/_default_take
