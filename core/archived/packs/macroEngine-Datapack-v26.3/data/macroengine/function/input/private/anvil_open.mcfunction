# macroengine:input/private/anvil_open  [INTERNAL]
# Reward of the macroengine:input/anvil_open advancement. @s = player who just
# opened an anvil. Starts (or restarts) the anvil session; see input/anvil.
advancement revoke @s only macroengine:input/anvil_open
tag @s add macroengine.anvil_session
tag @s remove macroengine.anvil_hidden
scoreboard players set @s macroengine.anvil_t 0
