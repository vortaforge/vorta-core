# macroengine:api/store/nbt/exists [MACRO]
# RETURN 1 when storage/path exists, else 0. Input (macro args): storage, path
execute if data storage macroengine:engine modules{store:0b} run return 0
$return run execute if data storage $(storage) $(path)
