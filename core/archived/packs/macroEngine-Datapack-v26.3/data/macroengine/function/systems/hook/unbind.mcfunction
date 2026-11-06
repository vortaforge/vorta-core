# ─────────────────────────────────────────────────────────────────
# macroengine:systems/hook/unbind
# Removes all binds belonging to a specific event.
#
# INPUT (storage macroengine:input):
# event → event name
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
function macroengine:core/internal/systems/hook/unbind_exec with storage macroengine:input {}
