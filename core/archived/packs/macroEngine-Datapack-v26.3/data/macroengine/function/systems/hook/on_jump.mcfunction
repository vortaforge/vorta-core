# macroengine:systems/hook/on_jump
# Binds a function or command to the "jumped" event.
#
# INPUT (storage macroengine:input):
#   func → function to run when a player jumps
#   cmd  → command to run when a player jumps (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_jump"
#   function macroengine:systems/hook/on_jump
#   -- or --
#   data modify storage macroengine:input cmd set value "say A player jumped"
#   function macroengine:systems/hook/on_jump
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "jumped"
function macroengine:systems/hook/bind
