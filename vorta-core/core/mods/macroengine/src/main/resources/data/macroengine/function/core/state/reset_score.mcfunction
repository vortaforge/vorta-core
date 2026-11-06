# macroengine:core/state/reset_score
# Resets a player's state to 0 (idle).
# Usage: /function macroengine:core/state/reset_score
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players set @s macroengine.state 0
