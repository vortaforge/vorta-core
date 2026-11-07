# macroengine:systems/hook/on_drop
# Binds a function or command to the "drop_item" event.
#
# INPUT (storage macroengine:input):
#   func → function to run when a player drops an item
#   cmd  → command to run when a player drops an item (used if func is absent)
#
# USAGE:
#   data modify storage macroengine:input func set value "mypack:on_drop"
#   function macroengine:systems/hook/on_drop
#   -- or --
#   data modify storage macroengine:input cmd set value "say An item was dropped"
#   function macroengine:systems/hook/on_drop
execute if data storage macroengine:engine modules{hook:0b} run return 0
data modify storage macroengine:input event set value "drop_item"
function macroengine:systems/hook/bind
