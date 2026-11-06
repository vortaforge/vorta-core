# macroengine:api/title/actionbar_p
# Action bar with %tokens% for @s. The text is rendered with api/store/render into a plain
# string (macroengine:store out.string); the component only exists while the command runs.
# INPUT macroengine:title in.text - string with %tokens%;  in.args - optional compound for %name%
# NOTE: uses macroengine:store in/out while it runs.
#
# Usage:
#   data modify storage macroengine:title in set value {text:"HP %health% | %player%"}
#   function macroengine:api/title/actionbar_p
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
data remove storage macroengine:store in
data modify storage macroengine:store in.template set value ""
execute if data storage macroengine:title in.text run data modify storage macroengine:store in.template set from storage macroengine:title in.text
execute if data storage macroengine:title in.args run data modify storage macroengine:store in.args set from storage macroengine:title in.args
execute unless function macroengine:api/store/render run return 0
title @s actionbar {"storage":"macroengine:store","nbt":"out.string","interpret":false,"plain":true}
