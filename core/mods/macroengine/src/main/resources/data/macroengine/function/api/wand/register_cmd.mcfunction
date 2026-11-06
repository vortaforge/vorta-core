# ─────────────────────────────────────────────────────────────────
# macroengine:api/wand/register_cmd
# Binds a raw command to a wand (carrot_on_a_stick).
#
# INPUT (storage macroengine:input):
#   tag → custom_data tag name
#   cmd → raw command to run
# ─────────────────────────────────────────────────────────────────
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{wand:0b} run return 0
execute unless data storage macroengine:engine wand_binds run data modify storage macroengine:engine wand_binds set value []
function macroengine:core/internal/api/wand/register_cmd_do with storage macroengine:input {}
