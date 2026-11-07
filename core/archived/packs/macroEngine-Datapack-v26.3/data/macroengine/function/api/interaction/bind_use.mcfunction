# macroengine:api/interaction/bind_use
# Binds a function to an interaction entity use (right-click) event.
#
# INPUT:
#   macroengine:input tag  — entity tag to match
#   macroengine:input func — function to call on use
#
# USAGE:
#   data modify storage macroengine:input tag set value "my_interact"
#   data modify storage macroengine:input func set value "mypack:on_use"
#   function macroengine:api/interaction/bind_use with storage macroengine:input {}
execute if data storage macroengine:engine modules{interaction:0b} run return 0
function macroengine:core/internal/api/interaction/bind_use_do with storage macroengine:input {}
