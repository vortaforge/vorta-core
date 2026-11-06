# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_not
# Negation: inverts the verdict of _mcmd_cond_eval.not.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg

execute if score $mcmd_cond_depth macroengine.tmp matches 8.. run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_error
execute if score $mcmd_cond_depth macroengine.tmp matches ..7 run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_not_enter with storage macroengine:engine _mcmd_depth_arg
