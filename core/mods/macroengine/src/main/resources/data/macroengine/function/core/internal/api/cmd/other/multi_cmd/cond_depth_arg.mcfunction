# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/cond_depth_arg
# Writes the current condition nesting depth into a macro argument
# compound so the recursive evaluators can build depth-indexed
# storage paths (a real stack, not a single shared slot).
#
# OUTPUT (storage macroengine:engine _mcmd_depth_arg): {d:<int>}
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result storage macroengine:engine _mcmd_depth_arg.d int 1 run scoreboard players get $mcmd_cond_depth macroengine.tmp
