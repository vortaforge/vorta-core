# ======================================================================================
# macroengine:events/register_once
# Like events/register, but does nothing when the same function is already registered
# for that event. Safe to call from a load function that runs on every /reload.
#
# INPUT  (storage macroengine:input events_reg):  event, func   (func = "namespace:path")
# OUTPUT macroengine:output result: 1b = registered now, 0b = already there or invalid input
# RETURN 1 when registered, 0 otherwise.
#
# event is checked with systems/validate/safe_name and func with
# systems/validate/function_id before either reaches a macro line.
#
# Usage:
#   data modify storage macroengine:input events_reg set value {event:"on_shop_open",func:"mypack:shop/open"}
#   function macroengine:events/register_once
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

return run function macroengine:core/internal/ext/events/register_once with storage macroengine:input events_reg
