# macroengine:api/store/nbt/shift [MACRO]
# Removes the FIRST element of the list at storage/path (queue behaviour) into macroengine:store nbt.result.
# Input (macro args): storage, path.  RETURN 1 when an element was removed, 0 otherwise.
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store nbt.result
$execute unless data storage $(storage) $(path)[0] run return 0
$data modify storage macroengine:store nbt.result set from storage $(storage) $(path)[0]
$data remove storage $(storage) $(path)[0]
return 1
