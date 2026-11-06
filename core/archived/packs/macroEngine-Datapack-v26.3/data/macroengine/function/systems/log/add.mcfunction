# macroengine:systems/log/add (internal)
# Called by error/warn/info/debug — do not call directly.
# Appends to the 30-entry ring buffer in macroengine:engine log_display.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{log:0b} run return 0
execute unless data storage macroengine:engine log_display run data modify storage macroengine:engine log_display set value []

$data modify storage macroengine:engine log_display append value {text:"[$(level)] $(message)",color:"$(color)"}

scoreboard players add #macroengine.log_count macroengine.tmp 1
execute if score #macroengine.log_count macroengine.tmp matches 31.. run data remove storage macroengine:engine log_display[0]
execute if score #macroengine.log_count macroengine.tmp matches 31.. run scoreboard players remove #macroengine.log_count macroengine.tmp 1
