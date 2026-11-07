# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_any_enter [MACRO]
# INPUT: $(d) — nesting depth
# ─────────────────────────────────────────────────────────────────

$data modify storage macroengine:engine _mcmd_cond_save_$(d) set from storage macroengine:engine _mcmd_cond_eval
$data modify storage macroengine:engine _mcmd_any_list_$(d) set from storage macroengine:engine _mcmd_cond_eval.any_of

scoreboard players add $mcmd_cond_depth macroengine.tmp 1
$scoreboard players set $mcmd_any_pass_$(d) macroengine.tmp 0

function macroengine:core/internal/api/cmd/other/multi_cmd/cond_any_loop with storage macroengine:engine _mcmd_depth_arg

scoreboard players remove $mcmd_cond_depth macroengine.tmp 1

$execute if score $mcmd_any_pass_$(d) macroengine.tmp matches 0 run scoreboard players set $mcmd_cond_result macroengine.tmp 0

$data modify storage macroengine:engine _mcmd_cond_eval set from storage macroengine:engine _mcmd_cond_save_$(d)
$data remove storage macroengine:engine _mcmd_cond_save_$(d)
$data remove storage macroengine:engine _mcmd_any_list_$(d)
$scoreboard players reset $mcmd_any_pass_$(d) macroengine.tmp
