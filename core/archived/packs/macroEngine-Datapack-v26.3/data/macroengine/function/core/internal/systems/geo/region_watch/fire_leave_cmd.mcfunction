# macroengine:systems/geo/region_watch/internal/fire_leave_cmd [MACRO]
# INPUT: $(on_leave_cmd) — from _rw_cur; called ONLY when on_leave_cmd field exists.
# @s = player leaving the region

$data modify storage macroengine:cmd_gate in.cmd set value "$(on_leave_cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$$(on_leave_cmd)
