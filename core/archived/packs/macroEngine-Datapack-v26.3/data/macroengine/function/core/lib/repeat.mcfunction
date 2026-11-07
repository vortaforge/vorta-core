$data modify storage macroengine:engine _repeat.func set value "$(func)"
$scoreboard players set $rep_n macroengine.tmp $(count)
scoreboard players set $rep_i macroengine.tmp 0
execute store result storage macroengine:engine _repeat.i int 1 run scoreboard players get $rep_i macroengine.tmp
execute store result storage macroengine:engine _repeat.remaining int 1 run scoreboard players get $rep_n macroengine.tmp
function macroengine:core/internal/core/lib/repeat_run
data remove storage macroengine:engine _repeat
