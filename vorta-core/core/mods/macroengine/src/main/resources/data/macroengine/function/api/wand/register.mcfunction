# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/register
# Registers a wand with a specific custom_data tag.
# On every item use, $(func) or $(cmd) runs.
#
# INPUT (storage macroengine:input):
#   tag  → custom_data tag name (e.g. "my_wand")
#   func → (optional) function to run
#   cmd  → (optional) command to run (if no func)
#
# USAGE:
#   data modify storage macroengine:input tag set value "fire_wand"
#   data modify storage macroengine:input func set value "mypack:on_fire_wand"
#   function macroengine:api/wand/register with storage macroengine:input {}
# ─────────────────────────────────────────────────────────────────
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{wand:0b} run return 0
execute unless data storage macroengine:engine wand_binds run data modify storage macroengine:engine wand_binds set value []
function macroengine:core/internal/api/wand/register_do with storage macroengine:input {}
