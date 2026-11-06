
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score #temp player_action.data if entity @a[distance=..10,tag=player_action.click_detection]
execute if score #temp player_action.data matches 0 run tp @s ~ -300 ~
execute if score #temp player_action.data matches 0 run kill @s
