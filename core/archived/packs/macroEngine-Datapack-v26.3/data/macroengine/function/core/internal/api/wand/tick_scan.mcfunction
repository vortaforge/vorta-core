# macroengine:api/wand/internal/tick_scan
# Every tick: detect players with macroengine.rightClick score 1+,
# check their held item, run the matching bind.

# Module toggle guard — skips this module when disabled via macroengine:api/toggle/wand/false
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine {modules:{wand:1b}} run return 0
scoreboard players operation #scan_mod macroengine.tick = #tick_ctr macroengine.tick
scoreboard players operation #scan_mod macroengine.tick %= #wand_interval macroengine.tick
execute unless score #scan_mod macroengine.tick matches 0 run return 0

execute unless data storage macroengine:engine wand_binds[0] run return 0

execute as @a[scores={macroengine.rightClick=1..}] at @s run function macroengine:core/internal/api/wand/dispatch
scoreboard players set @a[scores={macroengine.rightClick=1..}] macroengine.rightClick 0
