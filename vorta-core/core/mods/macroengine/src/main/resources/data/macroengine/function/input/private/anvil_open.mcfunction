# macroengine:input/private/anvil_open  [INTERNAL]
# Reward of the macroengine:input/anvil_open advancement. @s = player who just
# opened an anvil. Starts (or restarts) the anvil session; see input/anvil.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
advancement revoke @s only macroengine:input/anvil_open
tag @s add macroengine.anvil_session
tag @s remove macroengine.anvil_hidden
scoreboard players set @s macroengine.anvil_t 0
