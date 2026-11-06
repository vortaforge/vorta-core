execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{logic:0b} run return 0
$scoreboard players set $if_a macroengine.tmp $(a)
$scoreboard players set $if_b macroengine.tmp $(b)
$data modify storage macroengine:engine _dispatch.func set value "$(func)"
execute if score $if_a macroengine.tmp < $if_b macroengine.tmp run function #macroengine:internal/dispatch
