execute if data storage macroengine:engine modules{log:0b} run return 0
execute unless data storage macroengine:engine log_display[0] run tellraw @s {"text":"[Log] No entries.","color":"gray","italic":false}
execute unless data storage macroengine:engine log_display[0] run return 0

function macroengine:core/runtime/input_push
data modify storage macroengine:engine _felist_input set from storage macroengine:engine log_display
data modify storage macroengine:input func set value "macroengine:core/internal/systems/log/print_entry"
function macroengine:core/internal/core/lib/for_each_list with storage macroengine:input {}
function macroengine:core/runtime/input_pop
