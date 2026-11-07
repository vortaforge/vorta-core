# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/cooldown_check
# Checks whether the wand cooldown is active.
# NOTE: Wand cooldowns are stored under macroengine:engine wand_cooldowns;
#      this avoids collision with macroengine:cooldown module's "$(player).$(key)" path
# so there is zero risk of key collision.
#
# INPUT:
#   $(player) → player name
#   $(tag)    → wand tag
# OUTPUT:
# macroengine:output result → 0b=ready (no cooldown), 1b=cooldown active
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{wand:0b} run return 0
data modify storage macroengine:output result set value 0b

$execute unless data storage macroengine:engine wand_cooldowns.$(player).$(tag) run return 0

$execute store result score $wcc_exp macroengine.tmp run data get storage macroengine:engine wand_cooldowns.$(player).$(tag)
execute store result score $wcc_now macroengine.tmp run scoreboard players get $epoch macroengine.time

execute if score $wcc_now macroengine.tmp < $wcc_exp macroengine.tmp run data modify storage macroengine:output result set value 1b