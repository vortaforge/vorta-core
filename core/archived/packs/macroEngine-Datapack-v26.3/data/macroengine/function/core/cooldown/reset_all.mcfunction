# ─────────────────────────────────────────────────────────────────
# macroengine:core/cooldown/reset_all
# Clears all active cooldowns for a player.
#  Input : $(player) → player name
# Output: (side effect only)
#
# Example:
# data modify storage macroengine:input player set value "Steve"
# function macroengine:core/cooldown/reset_all with storage macroengine:input {}
# ─────────────────────────────────────────────────────────────────

$data remove storage macroengine:engine cooldowns.$(player)