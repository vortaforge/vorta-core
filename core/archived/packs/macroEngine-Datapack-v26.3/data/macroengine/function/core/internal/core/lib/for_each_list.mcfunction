$data modify storage macroengine:engine _felist_state set value {func:"$(func)"}
scoreboard players set $felist_i macroengine.tmp 0
function macroengine:core/internal/core/lib/for_each_list_step

data remove storage macroengine:engine _felist_input
data remove storage macroengine:engine _felist_state
data remove storage macroengine:engine _felist_current
