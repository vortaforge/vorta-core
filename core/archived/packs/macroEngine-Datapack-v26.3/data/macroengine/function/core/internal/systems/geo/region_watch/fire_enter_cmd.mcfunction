# macroengine:systems/geo/region_watch/internal/fire_enter_cmd [MACRO]
# INPUT: $(on_enter_cmd) — from _rw_cur; called ONLY when on_enter_cmd field exists.
# @s = player entering the region

$data modify storage macroengine:cmd_gate in.cmd set value "$(on_enter_cmd)"
execute unless function macroengine:systems/cmd_gate/check run return 0
$$(on_enter_cmd)
