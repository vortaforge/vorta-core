# ─────────────────────────────────────────────────────────────────
# macroengine:systems/hook/unbind
# Removes all binds belonging to a specific event.
#
# INPUT (storage macroengine:input):
# event → event name
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{hook:0b} run return 0
function macroengine:core/internal/systems/hook/unbind_exec with storage macroengine:input {}
