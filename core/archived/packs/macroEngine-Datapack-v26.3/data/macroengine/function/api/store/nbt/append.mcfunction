# macroengine:api/store/nbt/append [MACRO]
# Appends macroengine:store nbt.value to the list at storage/path. Input (macro args): storage, path
execute if data storage macroengine:engine modules{store:0b} run return 0
$data modify storage $(storage) $(path) append from storage macroengine:store nbt.value
