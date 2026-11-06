# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/batch/begin
# Starts a new batch or clears an existing one.
#
# INPUT (storage macroengine:input):
# id → batch id
# spread_over → how many ticks to spread over (default: 1)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/core/lib/batch/begin_exec with storage macroengine:input {}
