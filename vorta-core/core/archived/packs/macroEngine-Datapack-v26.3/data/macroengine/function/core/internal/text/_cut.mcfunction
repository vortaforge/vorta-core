# macroengine:core/internal/text/_cut [MACRO]
# INPUT $(a) $(b): win = substring [a, b) of storage macroengine:text s. Bounds must be valid.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$data modify storage macroengine:text win set string storage macroengine:text s $(a) $(b)
