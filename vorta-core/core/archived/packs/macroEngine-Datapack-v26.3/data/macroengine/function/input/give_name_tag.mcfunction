# Gives a marked name_tag ready for input capture.
# The player renames it (via anvil) then holds it to submit.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
give @s minecraft:name_tag[minecraft:custom_data={macroengine:{input:1b,inputItem:"name_tag"}}] 1
