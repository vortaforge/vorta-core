# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg
# Writes the current condition nesting depth into a macro argument
# compound so the recursive evaluators can build depth-indexed
# storage paths (a real stack, not a single shared slot).
#
# OUTPUT (storage macroengine:engine _mcmd_depth_arg): {d:<int>}
# ─────────────────────────────────────────────────────────────────

execute store result storage macroengine:engine _mcmd_depth_arg.d int 1 run scoreboard players get $mcmd_cond_depth macroengine.tmp
