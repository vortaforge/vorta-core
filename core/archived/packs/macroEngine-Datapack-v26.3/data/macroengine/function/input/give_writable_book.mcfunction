execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
give @s minecraft:writable_book[minecraft:custom_data={macroengine:{input:1b,inputItem:"writable_book"}}] 1
