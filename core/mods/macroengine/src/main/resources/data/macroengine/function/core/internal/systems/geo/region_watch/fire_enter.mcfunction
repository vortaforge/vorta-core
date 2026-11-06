# macroengine:systems/geo/region_watch/internal/fire_enter [MACRO]
# INPUT: $(on_enter) — from _rw_cur; called ONLY when on_enter field exists.
# @s = player entering the region

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:engine _dispatch.func set value "$(on_enter)"
function #macroengine:internal/dispatch
