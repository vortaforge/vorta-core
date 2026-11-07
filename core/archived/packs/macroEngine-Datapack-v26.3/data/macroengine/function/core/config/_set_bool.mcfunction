# macroengine:core/config/_set_bool [MACRO, INTERNAL]  $(key) is a schema key
execute store result score #cfg_in macroengine.tmp run data get storage macroengine:engine config_in.value
$execute if score #cfg_in macroengine.tmp matches ..0 run data modify storage macroengine:engine config.$(key) set value 0b
$execute if score #cfg_in macroengine.tmp matches 1.. run data modify storage macroengine:engine config.$(key) set value 1b
function macroengine:core/config/apply
return 1
