# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/batch/add
# Adds a job to the batch queue.
#
# INPUT (storage macroengine:input):
# id → batch id
# func → function to run (opsiyonel)
# cmd → command to run (optional, used if no func)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/core/lib/batch/add_exec with storage macroengine:input {}
