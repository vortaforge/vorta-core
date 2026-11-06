# macroengine:systems/sound/stop
# Stops a specific sound (and category) on a target selector.
#
# Input  (macroengine:input sound):
#   target   — selector string  e.g. "@a"  "@s"
#   category — source category  (use "*" to match all categories)
#   sound    — sound event ID   (use "*" to stop all sounds in category)
#
# Usage:
#   data modify storage macroengine:input sound set value \
#     {target:"@a",category:"*",sound:"*"}
#   function macroengine:systems/sound/stop with storage macroengine:input sound

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{sound:0b} run return 0
$stopsound $(target) $(category) $(sound)
