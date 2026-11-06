# macroengine:systems/geo/region_watch/internal/unregister_filter
# Iterates _rw_src list.
# Copies entries whose id does not match _rw_unbind_id to _rw_new.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine _rw_src[0] run return 0

data modify storage macroengine:engine _rw_cur set from storage macroengine:engine _rw_src[0]
data remove storage macroengine:engine _rw_src[0]

function macroengine:core/internal/systems/geo/region_watch/unregister_check with storage macroengine:engine _rw_cur

function macroengine:core/internal/systems/geo/region_watch/unregister_filter
