# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_not_enter [MACRO]
# INPUT: $(d) — nesting depth
#
# A depth overflow inside `not` fails closed (the child reports 0), which
# would invert to "passed". Restore an explicit not-passed verdict in that
# case so an over-deep tree can never pass.
# ─────────────────────────────────────────────────────────────────

$data modify storage macroengine:engine _mcmd_cond_save_$(d) set from storage macroengine:engine _mcmd_cond_eval

scoreboard players add $mcmd_cond_depth macroengine.tmp 1
$scoreboard players set $mcmd_not_depth_ok_$(d) macroengine.tmp 1
$execute if score $mcmd_cond_depth macroengine.tmp matches 9.. run scoreboard players set $mcmd_not_depth_ok_$(d) macroengine.tmp 0

$data modify storage macroengine:engine _mcmd_cond_eval set from storage macroengine:engine _mcmd_cond_save_$(d).not
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_eval_core
scoreboard players remove $mcmd_cond_depth macroengine.tmp 1

# Invert, unless the child bailed out on depth.
$execute if score $mcmd_not_depth_ok_$(d) macroengine.tmp matches 1 if score $mcmd_cond_result macroengine.tmp matches 1 run scoreboard players set $mcmd_not_inv_$(d) macroengine.tmp 0
$execute if score $mcmd_not_depth_ok_$(d) macroengine.tmp matches 1 if score $mcmd_cond_result macroengine.tmp matches 0 run scoreboard players set $mcmd_not_inv_$(d) macroengine.tmp 1
$execute if score $mcmd_not_depth_ok_$(d) macroengine.tmp matches 0 run scoreboard players set $mcmd_not_inv_$(d) macroengine.tmp 0
$execute if score $mcmd_not_depth_ok_$(d) macroengine.tmp matches 0 run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_error
$scoreboard players operation $mcmd_cond_result macroengine.tmp = $mcmd_not_inv_$(d) macroengine.tmp

$data modify storage macroengine:engine _mcmd_cond_eval set from storage macroengine:engine _mcmd_cond_save_$(d)
$data remove storage macroengine:engine _mcmd_cond_save_$(d)
$scoreboard players reset $mcmd_not_inv_$(d) macroengine.tmp
$scoreboard players reset $mcmd_not_depth_ok_$(d) macroengine.tmp
