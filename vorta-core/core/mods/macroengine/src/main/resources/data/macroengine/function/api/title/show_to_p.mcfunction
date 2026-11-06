# macroengine:api/title/show_to_p [MACRO]
# show_p for a named player. Input (macro arg): player. Storage input as show_p.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
$execute as @a[name=$(player),limit=1] run function macroengine:api/title/show_p
