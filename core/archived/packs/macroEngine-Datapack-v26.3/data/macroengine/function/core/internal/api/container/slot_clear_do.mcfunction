# macroengine:core/internal/api/container/slot_clear_do [INTERNAL]
# Body of api/container/slot_clear.
data modify storage macroengine:output container set value {ok:0b}
execute unless data storage macroengine:input slot run return 0
execute unless function macroengine:core/internal/api/container/_addr run return 0
return run function macroengine:core/internal/api/container/_slot_clear_m with storage macroengine:container tmp.k
