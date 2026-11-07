# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_any_of
# OR composition: at least one child in _mcmd_cond_eval.any_of must
# pass. Short-circuits on the first success.
# ─────────────────────────────────────────────────────────────────

function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg

execute if score $mcmd_cond_depth macroengine.tmp matches 8.. run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_error
execute if score $mcmd_cond_depth macroengine.tmp matches ..7 run function macroengine:core/internal/api/cmd/other/multi_cmd/cond_any_enter with storage macroengine:engine _mcmd_depth_arg
