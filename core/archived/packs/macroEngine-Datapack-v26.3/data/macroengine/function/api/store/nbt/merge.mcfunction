# macroengine:api/store/nbt/merge [MACRO]
# Merges the compound in macroengine:store nbt.value into storage/path. Input (macro args): storage, path
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
$data modify storage $(storage) $(path) merge from storage macroengine:store nbt.value
