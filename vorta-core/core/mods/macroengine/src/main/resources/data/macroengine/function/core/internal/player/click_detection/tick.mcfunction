
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #temp player_action.data if items entity @s weapon.mainhand *[minecraft:custom_data~{macroengine_player:{click_detection:1b}}]

execute if score #temp player_action.data matches 0 if entity @s[tag=player_action.click_detection] run function macroengine:core/internal/player/click_detection/end
execute if score #temp player_action.data matches 1 run function macroengine:core/internal/player/click_detection/process
