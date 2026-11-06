# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/cooldown_set
# Applies a cooldown to wand usage.
# NOTE: Wand cooldowns are stored under macroengine:engine wand_cooldowns;
#      this avoids collision with macroengine:cooldown module's "$(player).$(key)" path
# so there is zero risk of key collision.
#
# INPUT:
#   $(player)   → player name
#   $(tag)      → wand tag
#   $(duration) → cooldown duration (in ticks)
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{wand:0b} run return 0
$scoreboard players set $wcd_dur macroengine.tmp $(duration)
execute store result score $wcd_now macroengine.tmp run scoreboard players get $epoch macroengine.time
scoreboard players operation $wcd_now macroengine.tmp += $wcd_dur macroengine.tmp
$execute store result storage macroengine:engine wand_cooldowns.$(player).$(tag) int 1 run scoreboard players get $wcd_now macroengine.tmp