scoreboard players set $st_tog macroengine.tmp 0
$execute if data storage macroengine:engine {states:{$(player):"$(on)"}} run scoreboard players set $st_tog macroengine.tmp 1

$execute if score $st_tog macroengine.tmp matches 1 run data modify storage macroengine:engine states.$(player) set value "$(off)"
$execute if score $st_tog macroengine.tmp matches 0 run data modify storage macroengine:engine states.$(player) set value "$(on)"

data remove storage macroengine:output result
$data modify storage macroengine:output result set from storage macroengine:engine states.$(player)
