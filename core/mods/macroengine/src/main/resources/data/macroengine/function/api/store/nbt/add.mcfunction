# macroengine:api/store/nbt/add [MACRO]
# Adds `by` (negative to subtract) to the integer at storage/path; a missing path counts as 0.
# Input (macro args): storage, path, by.  RETURN the new value.
#
# Usage:  function macroengine:api/store/nbt/add {storage:"mypack:data",path:"stats.kills",by:1}
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{store:0b} run return 0
scoreboard players set #da_v macroengine.tmp 0
$execute store result score #da_v macroengine.tmp run data get storage $(storage) $(path)
$scoreboard players add #da_v macroengine.tmp $(by)
$execute store result storage $(storage) $(path) int 1 run scoreboard players get #da_v macroengine.tmp
return run scoreboard players get #da_v macroengine.tmp
