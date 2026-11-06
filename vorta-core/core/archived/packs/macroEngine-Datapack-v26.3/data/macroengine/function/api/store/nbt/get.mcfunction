# macroengine:api/store/nbt/get [MACRO]
# Reads one NBT value into macroengine:store nbt.result.
# Input (macro args): storage (e.g. "mypack:data"), path (e.g. "player.stats")
# RETURN 1 when the path exists (result set), 0 otherwise (result removed).
#
# Usage:  function macroengine:api/store/nbt/get {storage:"mypack:data",path:"motd"}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
data remove storage macroengine:store nbt.result
$execute unless data storage $(storage) $(path) run return 0
$data modify storage macroengine:store nbt.result set from storage $(storage) $(path)
return 1
