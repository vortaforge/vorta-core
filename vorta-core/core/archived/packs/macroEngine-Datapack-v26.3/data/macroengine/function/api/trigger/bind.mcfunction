execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{trigger:0b} run return 0
execute unless data storage macroengine:engine trigger_binds run data modify storage macroengine:engine trigger_binds set value []

$data modify storage macroengine:engine trigger_binds append value {value:$(value), func:"$(func)"}