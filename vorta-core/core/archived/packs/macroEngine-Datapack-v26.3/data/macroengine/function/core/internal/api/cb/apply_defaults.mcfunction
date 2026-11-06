# macroengine:api/cb/internal/apply_defaults
# Fills in missing x/y/z fields before the macro call.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:input cb.x run data modify storage macroengine:input cb.x set value 0
execute unless data storage macroengine:input cb.y run data modify storage macroengine:input cb.y set value -64
execute unless data storage macroengine:input cb.z run data modify storage macroengine:input cb.z set value 0
