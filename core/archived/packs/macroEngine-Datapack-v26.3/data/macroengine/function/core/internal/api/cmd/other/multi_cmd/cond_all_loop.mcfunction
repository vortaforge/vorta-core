# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_all_loop [MACRO]
# INPUT: $(d) — nesting depth. Consumes _mcmd_all_list_<d> one child at a
# time and stops as soon as one child fails.
# ─────────────────────────────────────────────────────────────────

$execute unless data storage macroengine:engine _mcmd_all_list_$(d)[0] run return 0
$execute if score $mcmd_all_pass_$(d) macroengine.tmp matches 0 run return 0

$data modify storage macroengine:engine _mcmd_cond_eval set from storage macroengine:engine _mcmd_all_list_$(d)[0]
$data remove storage macroengine:engine _mcmd_all_list_$(d)[0]

function macroengine:core/internal/api/cmd/other/multi_cmd/cond_eval_core

$execute if score $mcmd_cond_result macroengine.tmp matches 0 run scoreboard players set $mcmd_all_pass_$(d) macroengine.tmp 0

# A nested any_of/all_of/not overwrote _mcmd_depth_arg.d with its own depth.
# Re-derive it for THIS level (cond_depth is d+1 while inside the loop).
scoreboard players remove $mcmd_cond_depth macroengine.tmp 1
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg
scoreboard players add $mcmd_cond_depth macroengine.tmp 1
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_all_loop with storage macroengine:engine _mcmd_depth_arg
