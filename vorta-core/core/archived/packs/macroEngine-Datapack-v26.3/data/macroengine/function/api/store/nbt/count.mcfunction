# macroengine:api/store/nbt/count [MACRO]
# RETURN the length of the list/string or the number of keys of the compound at
# storage/path (0 when missing). Input (macro args): storage, path
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$execute unless data storage $(storage) $(path) run return 0
$return run data get storage $(storage) $(path)
