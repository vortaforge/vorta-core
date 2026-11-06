# ======================================================================================
# macroengine:events/has_func
# Checks whether one specific function is registered for an event (events/has only says
# whether the event has any handler at all).
#
# INPUT  (storage macroengine:input events_reg):  event, func
# OUTPUT macroengine:output result: 1b / 0b
# RETURN 1 when registered, 0 otherwise (also 0 for invalid input).
#
# Usage:
#   data modify storage macroengine:input events_reg set value {event:"on_shop_open",func:"mypack:shop/open"}
#   execute if function macroengine:events/has_func run say registered
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output result set value 0b
execute unless data storage macroengine:input events_reg.event run return 0
execute unless data storage macroengine:input events_reg.func run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input events_reg.event
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input events_reg.func
execute unless function macroengine:systems/validate/function_id run return 0

return run function macroengine:core/internal/ext/events/has_func with storage macroengine:input events_reg
