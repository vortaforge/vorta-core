# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/freeze/internal/anchor_tp  [INTERNAL]
# Called every tick via freeze/internal/tick, once per anchor stand.
# Execution context: AS = anchor armor stand, AT = stand's position.
#
# Reads this stand's macroengine.freeze_id into a tmp score, then teleports
# the frozen player whose macroengine.pid matches that value back to
# this exact position (~ ~ ~).
#
# The ~ ~ ~ resolves to the armor stand's world position because
# the calling execute chain set position with `at @s` on the stand.
# Switching executor to the player with `as @a[...]` does NOT reset
# the position — it remains at the stand. So `teleport @s ~ ~ ~`
# moves the player to the stand's feet. This runs once per tick,
# so players cannot escape regardless of client-side movement speed.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players operation $freeze_tp macroengine.tmp = @s macroengine.freeze_id
execute as @a[tag=macroengine.frozen] if score @s macroengine.pid = $freeze_tp macroengine.tmp run teleport @s ~ ~ ~
execute as @a[tag=macroengine.frozen] if score @s macroengine.pid = $freeze_tp macroengine.tmp run gamemode adventure @s
