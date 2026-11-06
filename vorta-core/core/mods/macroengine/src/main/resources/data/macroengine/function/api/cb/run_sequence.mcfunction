# macroengine:api/cb/run_sequence
# ─────────────────────────────────────────────────────────────────
# Schedules a list of commands to run sequentially, each separated
# by a configurable interval.
#
# INPUT  (storage macroengine:input cb):
#   cmds      (list of strings) — commands to run  [REQUIRED, min 1]
#   interval  (int)             — ticks between each command  [default: 2]
#   x         (int)             — CB block X  [default: 0]
#   y         (int)             — CB block Y  [default: -64]
#   z         (int)             — CB block Z  [default: 0]
#
# OUTPUT (storage macroengine:output):
#   cb_id   (int)  — one id shared by every step; api/cb/cancel_id cancels the
#                     steps that have not fired yet
#
# No permission gate — caller is trusted as-is.
#
# EXAMPLE:
#   data modify storage macroengine:input cb set value {cmds:["say one","say two","say three"],interval:20}
#   function macroengine:api/cb/run_sequence
# ─────────────────────────────────────────────────────────────────

# Verify required input
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute unless data storage macroengine:input cb.cmds[0] run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.cmds is empty or not set","color":"red"}]
execute unless data storage macroengine:input cb.cmds[0] run return 0

# Fill defaults
function macroengine:core/internal/api/cb/apply_defaults
execute unless data storage macroengine:input cb.interval run data modify storage macroengine:input cb.interval set value 2

# Expand cmds list into individual delayed queue entries
function macroengine:core/internal/systems/cb/seq_expand
data remove storage macroengine:input cb
