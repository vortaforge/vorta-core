# macroengine:systems/hook/on_eat
# Binds a function or command to the "eat" event.
#
# INPUT (storage macroengine:input):
#   func → function to run when a player eats
#   cmd  → command to run when a player eats (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_eat"
#   function macroengine:systems/hook/on_eat
#   -- or --
#   data modify storage macroengine:input cmd set value "say I ate something"
#   function macroengine:systems/hook/on_eat
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "eat"
function macroengine:systems/hook/bind
