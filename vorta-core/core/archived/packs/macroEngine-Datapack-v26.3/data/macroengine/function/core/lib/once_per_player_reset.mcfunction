# ─────────────────────────────────────────────────────────────────
# macroengine:core/lib/once_per_player_reset
# Deletes the once_per_player record — function can run again.
#  Input : $(player), $(key)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine once_per_player.$(player).$(key)
