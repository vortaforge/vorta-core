# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/fiber/is_alive
# Checks whether a fiber is active.
#
# INPUT (storage macroengine:input):
# id → fiber id
#
# OUTPUT (storage macroengine:output):
# result → 1b (active) | 0b (dead or never started)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/core/lib/fiber/is_alive_exec with storage macroengine:input {}
