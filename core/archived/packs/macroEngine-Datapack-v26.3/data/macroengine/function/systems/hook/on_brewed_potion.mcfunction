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

execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "brewed_potion"
function macroengine:systems/hook/bind
