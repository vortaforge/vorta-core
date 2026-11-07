# macroengine:systems/geo/region_watch/internal/unregister_exec [MACRO]
# INPUT: $(id)
# region_watches in list format — always run filter,
# if id not found, list remains unchanged.

execute unless data storage macroengine:engine region_watches run return 0

data modify storage macroengine:engine _rw_unbind_id set from storage macroengine:input id
data modify storage macroengine:engine _rw_new set value []
data modify storage macroengine:engine _rw_src set from storage macroengine:engine region_watches
function macroengine:core/internal/systems/geo/region_watch/unregister_filter
data modify storage macroengine:engine region_watches set from storage macroengine:engine _rw_new
data remove storage macroengine:engine _rw_new
data remove storage macroengine:engine _rw_src
data remove storage macroengine:engine _rw_unbind_id