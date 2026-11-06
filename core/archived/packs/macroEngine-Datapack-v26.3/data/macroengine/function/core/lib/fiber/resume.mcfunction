# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/fiber/resume
# Resumes a fiber immediately (no delay).
# Used to trigger a fiber step externally without yield.
#
# INPUT (storage macroengine:input):
# id → fiber id
# func → function to run
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/core/lib/fiber/resume_exec with storage macroengine:input {}
