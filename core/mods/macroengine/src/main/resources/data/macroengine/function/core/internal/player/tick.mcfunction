# macroEngine player module — heartbeat.
# Re-schedules itself, then runs the per-player pipeline for everyone online.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
schedule function macroengine:core/internal/player/tick 1t
execute as @a at @s run function macroengine:core/internal/player/player/tick
