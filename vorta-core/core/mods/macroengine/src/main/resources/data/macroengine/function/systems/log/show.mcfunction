execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{log:0b} run return 0
execute unless data storage macroengine:engine log_display[0] run tellraw @s {"text":"[Log] No entries.","color":"gray","italic":false}
execute unless data storage macroengine:engine log_display[0] run return 0

function macroengine:core/lib/input_push
data modify storage macroengine:engine _felist_input set from storage macroengine:engine log_display
data modify storage macroengine:input func set value "macroengine:core/internal/systems/log/print_entry"
function macroengine:core/lib/for_each_list with storage macroengine:input {}
function macroengine:core/lib/input_pop
