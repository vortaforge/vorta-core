execute if data storage macroengine:engine modules{logic:0b} run return 0
$scoreboard players set $if_a macroengine.tmp $(a)
$scoreboard players set $if_b macroengine.tmp $(b)
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute if score $if_a macroengine.tmp = $if_b macroengine.tmp run function #macroengine:internal/dispatch
