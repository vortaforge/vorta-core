# macroengine:api/store/nbt/merge [MACRO]
# Merges the compound in macroengine:store nbt.value into storage/path. Input (macro args): storage, path
execute if data storage macroengine:engine modules{store:0b} run return 0
$data modify storage $(storage) $(path) merge from storage macroengine:store nbt.value
