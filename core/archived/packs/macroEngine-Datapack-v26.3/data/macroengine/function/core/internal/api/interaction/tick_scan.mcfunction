# Module toggle guard — skips this module when disabled via macroengine:api/toggle/interaction/false
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:engine {modules:{interaction:1b}} run return 0
scoreboard players operation #scan_mod macroengine.tick = #tick_ctr macroengine.tick
scoreboard players operation #scan_mod macroengine.tick %= #interaction_interval macroengine.tick
execute unless score #scan_mod macroengine.tick matches 0 run return 0

execute unless entity @e[type=minecraft:interaction,tag=macroengine.interaction,limit=1] run return 0

execute if data storage macroengine:engine interaction_binds.attack[0] run execute as @e[type=minecraft:interaction,tag=macroengine.interaction] if data entity @s attack run function macroengine:core/internal/api/interaction/on_attack

execute if data storage macroengine:engine interaction_binds.use[0] run execute as @e[type=minecraft:interaction,tag=macroengine.interaction] if data entity @s interaction run function macroengine:core/internal/api/interaction/on_use
