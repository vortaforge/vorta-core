# ─────────────────────────────────────────────────────────────────
# macroengine:systems/rng/pick [MACRO]
# Chooses one element uniformly at random from a list.
#
# INPUT:  $(list) — any NBT list
# OUTPUT: macroengine:output result — the chosen element
#         macroengine:output index  — its position in the input
#
# An empty list leaves output.result untouched and sets index to -1, so
# a caller can tell "nothing to pick" from "picked the first element".
#
# Usage:  function macroengine:systems/rng/pick {list:["a","b","c"]}
# ─────────────────────────────────────────────────────────────────

execute if data storage macroengine:engine modules{rng:0b} run return 0
$data modify storage macroengine:engine _rng_list set value $(list)

execute store result score $rng_len macroengine.tmp run data get storage macroengine:engine _rng_list

execute if score $rng_len macroengine.tmp matches ..0 run data modify storage macroengine:output index set value -1
execute if score $rng_len macroengine.tmp matches ..0 run data remove storage macroengine:engine _rng_list
execute if score $rng_len macroengine.tmp matches ..0 run return 0

scoreboard players remove $rng_len macroengine.tmp 1

data modify storage macroengine:engine _rng_arg set value {min:0}
execute store result storage macroengine:engine _rng_arg.max int 1 run scoreboard players get $rng_len macroengine.tmp
function macroengine:systems/rng/int with storage macroengine:engine _rng_arg

execute store result storage macroengine:output index int 1 run data get storage macroengine:output result
function macroengine:core/internal/systems/rng/_pick_at with storage macroengine:output

data remove storage macroengine:engine _rng_list
data remove storage macroengine:engine _rng_arg
scoreboard players reset $rng_len macroengine.tmp
