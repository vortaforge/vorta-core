# macroengine:api/cb/cancel
# ─────────────────────────────────────────────────────────────────
# Clears all pending delayed CB commands from the queue.
#
# No input required. Clears the entire queue.
#
# No permission gate — caller is trusted as-is.
#
# EXAMPLE:
#   function macroengine:api/cb/cancel
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{cb:0b} run return 0
data remove storage macroengine:engine cb_queue
data modify storage macroengine:engine cb_queue set value []
