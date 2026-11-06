
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
schedule function macroengine:core/internal/player/click_detection/tick_entities 100t
execute as @e[type=minecraft:interaction,tag=player_action.click_entity] at @s run function macroengine:core/internal/player/click_detection/tick_entities_2
