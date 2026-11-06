# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one [MACRO]
# INPUT: $(d) — one nesting depth level
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine _mcmd_cond_save_$(d)
$data remove storage macroengine:engine _mcmd_all_list_$(d)
$data remove storage macroengine:engine _mcmd_any_list_$(d)
$scoreboard players reset $mcmd_all_pass_$(d) macroengine.tmp
$scoreboard players reset $mcmd_any_pass_$(d) macroengine.tmp
$scoreboard players reset $mcmd_not_inv_$(d) macroengine.tmp
$scoreboard players reset $mcmd_not_depth_ok_$(d) macroengine.tmp
