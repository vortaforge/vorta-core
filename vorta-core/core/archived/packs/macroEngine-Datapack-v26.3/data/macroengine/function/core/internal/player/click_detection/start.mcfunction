
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tag @s add player_action.click_detection
summon minecraft:interaction ~ ~ ~ {Tags:["player_action.click_entity","player_action.new","smithed.entity","smithed.strict"]}
execute as @e[type=minecraft:interaction,tag=player_action.new] at @s run function macroengine:core/internal/player/click_detection/start_2
