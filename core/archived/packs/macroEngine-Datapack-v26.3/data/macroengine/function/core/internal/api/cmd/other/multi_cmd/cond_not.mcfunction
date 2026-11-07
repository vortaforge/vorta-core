# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_not
# Negation: inverts the verdict of _mcmd_cond_eval.not.
# ─────────────────────────────────────────────────────────────────

function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg

execute if score $mcmd_cond_depth macroengine.tmp matches 8.. run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_error
execute if score $mcmd_cond_depth macroengine.tmp matches ..7 run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_not_enter with storage macroengine:engine _mcmd_depth_arg
