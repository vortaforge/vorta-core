execute if data storage macroengine:engine modules{trigger:0b} run return 0
execute unless data storage macroengine:engine trigger_binds run data modify storage macroengine:engine trigger_binds set value []

$data modify storage macroengine:engine trigger_binds append value {value:$(value), cmd:"$(cmd)"}