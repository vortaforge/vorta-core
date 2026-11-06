# macroengine:api/title/show_area_p [MACRO]
# show_p for every player within `radius` blocks of the position the function runs at.
# Input (macro arg): radius. Storage input as show_p.
#
# Usage:  execute positioned 0 64 0 run function macroengine:api/title/show_area_p {radius:32}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
$execute as @a[distance=..$(radius)] run function macroengine:api/title/show_p
