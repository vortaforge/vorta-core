# Raycast start
# Reset distance counter (max 50 steps = 5 blocks)
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{hook:0b} run return 0
scoreboard players set @s macroengine.tmp 0

# Start loop
function macroengine:systems/hook/raycast/loop
