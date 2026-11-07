# macroengine:core/config/_set_int [MACRO, INTERNAL]  $(key) is a schema key; value is clamped to min..max
execute store result score #cfg_in macroengine.tmp run data get storage macroengine:engine config_in.value
execute store result score #cfg_min macroengine.tmp run data get storage macroengine:engine config_sc.min
execute store result score #cfg_max macroengine.tmp run data get storage macroengine:engine config_sc.max
execute if score #cfg_in macroengine.tmp < #cfg_min macroengine.tmp run scoreboard players operation #cfg_in macroengine.tmp = #cfg_min macroengine.tmp
execute if score #cfg_in macroengine.tmp > #cfg_max macroengine.tmp run scoreboard players operation #cfg_in macroengine.tmp = #cfg_max macroengine.tmp
$execute store result storage macroengine:engine config.$(key) int 1 run scoreboard players get #cfg_in macroengine.tmp
function macroengine:core/config/apply
return 1
