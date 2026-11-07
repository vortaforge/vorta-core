# macroengine:api/store/nbt/set_default [MACRO]
# Writes macroengine:store nbt.value to storage/path ONLY when the path does not exist yet
# (first-run initialisation that never overwrites live data).
# Input (macro args): storage, path.  RETURN 1 when it wrote, 0 when it already existed.
execute if data storage macroengine:engine modules{store:0b} run return 0
$execute if data storage $(storage) $(path) run return 0
$data modify storage $(storage) $(path) set from storage macroengine:store nbt.value
return 1
