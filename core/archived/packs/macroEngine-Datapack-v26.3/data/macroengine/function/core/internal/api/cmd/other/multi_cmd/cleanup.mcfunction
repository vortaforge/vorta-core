# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cleanup
# Cleanup — remove temporary storages
# ─────────────────────────────────────────────────────────────────

data remove storage macroengine:engine _mcmd_queue
data remove storage macroengine:engine _mcmd_current
data remove storage macroengine:engine _mcmd_exec
data remove storage macroengine:engine _mcmd_cond_tmp

# Condition evaluator (leaves + composition)
data remove storage macroengine:engine _mcmd_cond_eval
data remove storage macroengine:engine _mcmd_depth_arg

# Nested group expansion
data remove storage macroengine:engine _mcmd_newq
data remove storage macroengine:engine _mcmd_oldq

# Sort temporaries (no-op if sort was not used)
data remove storage macroengine:engine _sort_neg
data remove storage macroengine:engine _sort_zero
data remove storage macroengine:engine _sort_pos
data remove storage macroengine:engine _sort_buf
data remove storage macroengine:engine _sort_tmp
data remove storage macroengine:engine _sort_cur

# Composition leaves keep per-depth keys; clear the whole depth range the
# evaluators are allowed to use (see cond_depth_error).
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth

scoreboard players reset $mcmd_skipped macroengine.tmp
scoreboard players reset $mcmd_cond_result macroengine.tmp
scoreboard players reset $mcmd_cond_score macroengine.tmp
scoreboard players reset $mcmd_cond_ok macroengine.tmp
scoreboard players reset $mcmd_cond_depth macroengine.tmp
scoreboard players reset $sort_pri macroengine.tmp
