# macroengine:api/store/nbt/exists [MACRO]
# RETURN 1 when storage/path exists, else 0. Input (macro args): storage, path
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$return run execute if data storage $(storage) $(path)
