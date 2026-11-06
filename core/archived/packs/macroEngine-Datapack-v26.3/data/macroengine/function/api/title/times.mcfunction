# macroengine:api/title/times [MACRO]
# Sets title timing for a player without showing anything.
# Input (macro args): player, fade_in, stay, fade_out (ticks)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{title:0b} run return 0
$title @a[name=$(player),limit=1] times $(fade_in) $(stay) $(fade_out)
