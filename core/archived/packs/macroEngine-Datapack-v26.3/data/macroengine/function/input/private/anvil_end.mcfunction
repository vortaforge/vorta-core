# macroengine:input/private/anvil_end  [INTERNAL]
# @s = player. Closes the anvil session.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tag @s remove macroengine.anvil_session
tag @s remove macroengine.anvil_hidden
scoreboard players reset @s macroengine.anvil_t
