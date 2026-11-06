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

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data remove storage macroengine:engine cooldowns.$(player)