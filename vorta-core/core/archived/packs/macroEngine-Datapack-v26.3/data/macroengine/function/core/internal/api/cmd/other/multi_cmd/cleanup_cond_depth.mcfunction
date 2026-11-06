# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth
# Removes the depth-indexed temporaries created by all_of / any_of / not.
# The evaluators allow depths 0..8 (see cond_depth_error), so the unrolled
# list below covers every key they can create.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:0}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:1}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:2}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:3}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:4}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:5}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:6}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:7}
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup_cond_depth_one {d:8}
