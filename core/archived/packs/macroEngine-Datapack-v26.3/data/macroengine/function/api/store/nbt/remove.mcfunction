# macroengine:api/store/nbt/remove [MACRO]
# Removes storage/path. Input (macro args): storage, path
execute if data storage macroengine:engine modules{store:0b} run return 0
$data remove storage $(storage) $(path)
