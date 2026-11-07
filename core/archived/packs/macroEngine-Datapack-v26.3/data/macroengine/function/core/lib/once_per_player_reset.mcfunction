# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/once_per_player_reset
# Deletes the once_per_player record — function can run again.
#  Input : $(player), $(key)
# ─────────────────────────────────────────────────────────────────

$data remove storage macroengine:engine once_per_player.$(player).$(key)
