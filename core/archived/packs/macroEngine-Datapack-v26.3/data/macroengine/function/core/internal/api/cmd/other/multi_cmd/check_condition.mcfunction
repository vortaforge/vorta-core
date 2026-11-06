# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/check_condition
# Public entry point. Evaluates the condition attached to the command
# currently being executed and writes the verdict to
# $mcmd_cond_result macroengine.tmp (1 = passed, 0 = not passed).
#
# INPUT (storage macroengine:engine _mcmd_current.condition)
#
# The full supported schema is documented in cond_eval_core.mcfunction.
# ─────────────────────────────────────────────────────────────────

# Depth 0 for a top-level evaluation.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set $mcmd_cond_depth macroengine.tmp 0

data modify storage macroengine:engine _mcmd_cond_eval set from storage macroengine:engine _mcmd_current.condition
function macroengine:core/internal/api/cmd/other/multi_cmd/cond_eval_core

data remove storage macroengine:engine _mcmd_cond_eval
