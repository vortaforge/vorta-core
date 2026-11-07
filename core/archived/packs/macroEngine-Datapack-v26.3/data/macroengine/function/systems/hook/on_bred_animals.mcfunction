# ======================================================================================
# macroengine:systems/hook/on_bred_animals
# Binds a function or command to the "bred_animals" event (fires when a player breeds two animals).
#
# INPUT (storage macroengine:input):
#   func -> function to run, as the player
#   cmd  -> command to run (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_bred_animals"
#   function macroengine:systems/hook/on_bred_animals
# ======================================================================================

execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "bred_animals"
function macroengine:systems/hook/bind
