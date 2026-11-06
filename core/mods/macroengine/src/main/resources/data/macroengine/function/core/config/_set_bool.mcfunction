# macroengine:core/config/_set_bool [MACRO, INTERNAL]  $(key) is a schema key
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #cfg_in macroengine.tmp run data get storage macroengine:engine config_in.value
$execute if score #cfg_in macroengine.tmp matches ..0 run data modify storage macroengine:engine config.$(key) set value 0b
$execute if score #cfg_in macroengine.tmp matches 1.. run data modify storage macroengine:engine config.$(key) set value 1b
function macroengine:core/config/apply
return 1
