# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/freeze/tick  [INTERNAL — runs via #macroengine:loop]
# Hooked into #macroengine:loop (listed in tags/function/loop.json; core/tick runs that tag as every online player each tick).
#
# Early-exit if no frozen players exist — zero cost when the
# freeze system is idle.
#
# For each anchor stand: switch execution position to the stand,
# then delegate to anchor_tp which identifies and teleports the
# matching frozen player back to that position.
# ─────────────────────────────────────────────────────────────────

# Fast exit — no frozen players, nothing to do
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless entity @a[tag=macroengine.frozen] run return 0

# Iterate anchor stands and teleport their linked players back
execute as @e[tag=macroengine.freeze_anchor] at @s run function macroengine:core/internal/api/cmd/freeze/anchor_tp
