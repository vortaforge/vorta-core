# macroengine:api/store/nbt/pop [MACRO]
# Removes the LAST element of the list at storage/path and puts it in macroengine:store nbt.result.
# Input (macro args): storage, path.  RETURN 1 when an element was popped, 0 for an empty/missing list.
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store nbt.result
$execute unless data storage $(storage) $(path)[-1] run return 0
$data modify storage macroengine:store nbt.result set from storage $(storage) $(path)[-1]
$data remove storage $(storage) $(path)[-1]
return 1
