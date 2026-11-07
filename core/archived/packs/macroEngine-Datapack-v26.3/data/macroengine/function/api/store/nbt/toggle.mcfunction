# macroengine:api/store/nbt/toggle [MACRO]
# Flips the byte flag at storage/path (missing counts as 0b -> becomes 1b).
# Input (macro args): storage, path.  RETURN the new value (0 or 1).
execute if data storage macroengine:engine modules{store:0b} run return 0
scoreboard players set #da_v macroengine.tmp 0
$execute store result score #da_v macroengine.tmp run data get storage $(storage) $(path)
execute store success score #da_v macroengine.tmp if score #da_v macroengine.tmp matches 0
$execute store result storage $(storage) $(path) byte 1 run scoreboard players get #da_v macroengine.tmp
return run scoreboard players get #da_v macroengine.tmp
