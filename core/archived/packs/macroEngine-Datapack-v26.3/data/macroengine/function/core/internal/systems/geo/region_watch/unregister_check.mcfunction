# macroengine:systems/geo/region_watch/internal/unregister_check [MACRO]
# INPUT: $(id) — _rw_cur'dan beslenir
# If id does not match, add to _rw_new (keep).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$execute unless data storage macroengine:engine {_rw_unbind_id:"$(id)"} run data modify storage macroengine:engine _rw_new append from storage macroengine:engine _rw_cur
