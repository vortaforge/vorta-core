execute if data storage macroengine:engine modules{perm:0b} run return 0
$scoreboard objectives add $(name) trigger

$execute unless data storage macroengine:engine perm_triggers.$(name) run data modify storage macroengine:engine perm_triggers.$(name) set value []
$data modify storage macroengine:engine perm_triggers.$(name) append value {value:$(value), func:"$(func)", perm:"$(perm)"}

execute unless data storage macroengine:engine perm_trigger_names run data modify storage macroengine:engine perm_trigger_names set value []
$execute unless data storage macroengine:engine perm_trigger_names[{name:"$(name)"}] run data modify storage macroengine:engine perm_trigger_names append value {name:"$(name)"}