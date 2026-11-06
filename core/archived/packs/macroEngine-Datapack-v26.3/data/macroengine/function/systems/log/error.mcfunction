# macroengine:systems/log/error
# Usage: $function macroengine:systems/log/error {message:"[System] Something failed"}
# Level: 1 — always shown unless log is off
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{log:0b} run return 0
$data modify storage macroengine:engine _log_add_tmp.message set value "$(message)"
data modify storage macroengine:engine _log_add_tmp.level set value "ERROR"
data modify storage macroengine:engine _log_add_tmp.color set value "red"
execute if score #macroengine.log_level macroengine.log_level matches 1.. run function macroengine:systems/log/add with storage macroengine:engine _log_add_tmp
