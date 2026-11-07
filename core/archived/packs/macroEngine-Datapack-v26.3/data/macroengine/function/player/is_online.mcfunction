# ─────────────────────────────────────────────────────────────────
# macroengine:player/is_online
# Checks whether the player is on the server.
#  Input : $(player) → player name
# Output: macroengine:output result → 1b (online) / 0b (offline)
# ─────────────────────────────────────────────────────────────────

data modify storage macroengine:output result set value 0b
$execute if entity @a[name=$(player),limit=1] run data modify storage macroengine:output result set value 1b
