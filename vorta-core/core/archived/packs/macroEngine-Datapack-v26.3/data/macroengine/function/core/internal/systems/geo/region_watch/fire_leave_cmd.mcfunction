# macroengine:systems/geo/region_watch/internal/fire_leave_cmd [MACRO]
# INPUT: $(on_leave_cmd) — from _rw_cur; called ONLY when on_leave_cmd field exists.
# @s = player leaving the region

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:cmd_gate in.cmd set value "$(on_leave_cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$$(on_leave_cmd)
