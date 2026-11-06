# ======================================================================================
# macroengine:world/entity/count_near
# Counts entities of one type within a radius of the executor's position.
#
# INPUT  (storage macroengine:input world):
#   type    namespaced entity type, e.g. "minecraft:zombie" (tags are not accepted)
#   radius  blocks, clamped to 1..1024. Must be a real NBT number (not a string).
# OUTPUT macroengine:output count (int)
# RETURN the count (0 for invalid input).
#
# type is checked with systems/validate/function_id (namespace:path shape, every piece
# through safe_name) before it reaches the selector. The executor itself is counted when
# it matches the type.
#
# Usage:
#   data modify storage macroengine:input world set value {type:"minecraft:zombie",radius:32}
#   execute as @a[limit=1] at @s run function macroengine:world/entity/count_near
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:output count set value 0
execute unless data storage macroengine:input world.type run return 0
execute unless data storage macroengine:input world.radius run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input world.type
execute unless function macroengine:systems/validate/function_id run return 0

execute store result score #ext_wn_r macroengine.tmp run data get storage macroengine:input world.radius
execute if score #ext_wn_r macroengine.tmp matches ..0 run scoreboard players set #ext_wn_r macroengine.tmp 1
execute if score #ext_wn_r macroengine.tmp matches 1025.. run scoreboard players set #ext_wn_r macroengine.tmp 1024
data modify storage macroengine:engine _ext_wn set value {}
data modify storage macroengine:engine _ext_wn.type set from storage macroengine:input world.type
execute store result storage macroengine:engine _ext_wn.r int 1 run scoreboard players get #ext_wn_r macroengine.tmp
function macroengine:core/internal/ext/world/count_near with storage macroengine:engine _ext_wn
data remove storage macroengine:engine _ext_wn
return run data get storage macroengine:output count
