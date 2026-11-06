# macroengine:core/state/set_score
# Sets a player's integer state on the macroengine.state scoreboard.
# Usage: $function macroengine:core/state/set_score {value:1}
# States: 0=idle 1=combat 2=menu (define your own)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
$scoreboard players set @s macroengine.state $(value)
