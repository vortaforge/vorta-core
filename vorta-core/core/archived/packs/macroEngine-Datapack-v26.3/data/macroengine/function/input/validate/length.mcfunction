# ======================================================================================
# macroengine:input/validate/length [MACRO]
# Length check for captured text. Run it AFTER a capture, next to input/validate/check.
# Reads the value; never executes or pastes it.
#
# INPUT (macro args): source  dot-path INTO macroengine:input, e.g. "book.raw"
#                     min     smallest allowed length (>= 0)
#                     max     largest allowed length
#       source/min/max are written by the datapack author, not by players.
# OUTPUT (storage macroengine:input_validate result):
#   valid   1b when min <= length <= max, else 0b
#   length  the measured length (only when the value exists)
#   error   reason when invalid
# RETURN 1 when valid, 0 otherwise.
#
# Length is counted in UTF-16 code units, which is what 'data get' reports for a string.
#
# Usage:
#   function macroengine:input/validate/length {source:"book.raw",min:1,max:32}
#   execute if data storage macroengine:input_validate result{valid:1b} run ...
# ======================================================================================

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data remove storage macroengine:input_validate result
data modify storage macroengine:input_validate result.valid set value 0b
$execute unless data storage macroengine:input $(source) run data modify storage macroengine:input_validate result.error set value "no value"
$execute unless data storage macroengine:input $(source) run return 0

data remove storage macroengine:input_validate _ext
$data modify storage macroengine:input_validate _ext.s set string storage macroengine:input $(source)
execute unless data storage macroengine:input_validate _ext.s run data modify storage macroengine:input_validate result.error set value "not a string"
execute unless data storage macroengine:input_validate _ext.s run return 0

execute store result score #ext_len macroengine.tmp run data get storage macroengine:input_validate _ext.s
data remove storage macroengine:input_validate _ext
execute store result storage macroengine:input_validate result.length int 1 run scoreboard players get #ext_len macroengine.tmp
$scoreboard players set #ext_lmin macroengine.tmp $(min)
$scoreboard players set #ext_lmax macroengine.tmp $(max)

execute if score #ext_len macroengine.tmp < #ext_lmin macroengine.tmp run data modify storage macroengine:input_validate result.error set value "too short"
execute if score #ext_len macroengine.tmp < #ext_lmin macroengine.tmp run return 0
execute if score #ext_len macroengine.tmp > #ext_lmax macroengine.tmp run data modify storage macroengine:input_validate result.error set value "too long"
execute if score #ext_len macroengine.tmp > #ext_lmax macroengine.tmp run return 0

data modify storage macroengine:input_validate result.valid set value 1b
return 1
