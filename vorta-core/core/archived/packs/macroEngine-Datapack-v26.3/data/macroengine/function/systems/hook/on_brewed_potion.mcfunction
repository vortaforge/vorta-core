# ======================================================================================
# macroengine:systems/hook/on_brewed_potion
# Binds a function or command to the "brewed_potion" event (fires when a player takes a potion out of a brewing stand).
#
# INPUT (storage macroengine:input):
#   func -> function to run, as the player
#   cmd  -> command to run (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_brewed_potion"
#   function macroengine:systems/hook/on_brewed_potion
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "brewed_potion"
function macroengine:systems/hook/bind
