$data modify storage macroengine:engine _swap.tmp set from storage macroengine:engine players.$(player_a).$(key)
$data modify storage macroengine:engine players.$(player_a).$(key) set from storage macroengine:engine players.$(player_b).$(key)
$data modify storage macroengine:engine players.$(player_b).$(key) set from storage macroengine:engine _swap.tmp
data remove storage macroengine:engine _swap
