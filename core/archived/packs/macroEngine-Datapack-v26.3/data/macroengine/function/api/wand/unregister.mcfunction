# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/unregister
# Removes all wand binds belonging to a specific tag.
#
# INPUT (storage macroengine:input):
# tag → wand tag to remove
#
# EXAMPLE:
# data modify storage macroengine:input tag set value "fire_wand"
# function macroengine:api/wand/unregister
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{wand:0b} run return 0
function macroengine:core/internal/api/wand/unregister_exec with storage macroengine:input {}
