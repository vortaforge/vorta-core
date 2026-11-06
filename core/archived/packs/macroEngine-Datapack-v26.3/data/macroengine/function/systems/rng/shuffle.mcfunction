# ======================================================================================
# macroengine:systems/rng/shuffle
# Shuffles a list with the seeded generator (Fisher-Yates), so a shuffle can be replayed
# with systems/rng/seed exactly like every other systems/rng function.
#
# INPUT  (storage macroengine:input shuffle):  list   any NBT list
# OUTPUT macroengine:output result: a shuffled COPY; the input list is not modified
# RETURN the number of elements shuffled.
#        0 (and output.result untouched) for an empty list, a value that is not a list,
#        or a list longer than 500 elements (one tick has a command budget).
#
# The list is read from storage and never pasted into a command, unlike systems/rng/pick.
#
# Usage:
#   data modify storage macroengine:input shuffle.list set value ["a","b","c","d"]
#   function macroengine:systems/rng/shuffle
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{rng:0b} run return 0
data remove storage macroengine:output result
execute unless data storage macroengine:input shuffle.list[0] run return 0

data modify storage macroengine:engine _ext_shf set from storage macroengine:input shuffle.list
execute store result score #ext_shf_n macroengine.tmp run data get storage macroengine:engine _ext_shf
execute if score #ext_shf_n macroengine.tmp matches 501.. run data remove storage macroengine:engine _ext_shf
execute if score #ext_shf_n macroengine.tmp matches 501.. run return 0

scoreboard players operation #ext_shf_i macroengine.tmp = #ext_shf_n macroengine.tmp
scoreboard players remove #ext_shf_i macroengine.tmp 1
execute if score #ext_shf_i macroengine.tmp matches 1.. run function macroengine:core/internal/ext/rng/shuffle_step

data modify storage macroengine:output result set from storage macroengine:engine _ext_shf
data remove storage macroengine:engine _ext_shf
data remove storage macroengine:engine _ext_shf_arg
data remove storage macroengine:engine _ext_shf_t
return run scoreboard players get #ext_shf_n macroengine.tmp
