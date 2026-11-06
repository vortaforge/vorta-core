# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/fiber/spawn
# Starts a new fiber and immediately runs its first step.
# If spawned with the same id, the existing fiber is replaced.
#
# INPUT (storage macroengine:input):
# id → fiber id (unique string)
# func → function name to start
#
# EXAMPLE:
# data modify storage macroengine:input id set value "boss_intro"
# data modify storage macroengine:input func set value "mypack:boss/step_0"
# function macroengine:core/lib/fiber/spawn
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/core/lib/fiber/spawn_exec with storage macroengine:input {}
