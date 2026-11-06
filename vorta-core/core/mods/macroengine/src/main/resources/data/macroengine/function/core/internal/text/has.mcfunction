# macroengine:core/internal/text/has
# INPUT macroengine:text: s, needle.  RETURN 1 if s contains needle, else 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:text n set value 1
return run function macroengine:core/internal/text/find
