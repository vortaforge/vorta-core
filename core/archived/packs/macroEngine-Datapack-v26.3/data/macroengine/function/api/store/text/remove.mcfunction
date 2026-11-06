# macroengine:api/store/text/remove
# Removes one language of a template. INPUT macroengine:store in.name, in.lang. RETURN 1 / 0.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store tmp
execute unless function macroengine:core/internal/api/store/_name run return 0
execute unless function macroengine:core/internal/api/store/_lang run return 0
return run function macroengine:core/internal/api/store/_t_remove with storage macroengine:store tmp.k
