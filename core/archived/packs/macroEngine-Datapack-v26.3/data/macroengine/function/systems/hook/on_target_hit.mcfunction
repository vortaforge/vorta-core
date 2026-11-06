# macroengine:systems/hook/on_target_hit
# Binds a function or command to the "target_hit" event.
#
# INPUT (storage macroengine:input):
#   func → function to run when a player hits a target block
#   cmd  → command to run when a player hits a target block (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_target_hit"
#   function macroengine:systems/hook/on_target_hit
#   -- or --
#   data modify storage macroengine:input cmd set value "say Target hit"
#   function macroengine:systems/hook/on_target_hit
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "target_hit"
function macroengine:systems/hook/bind
