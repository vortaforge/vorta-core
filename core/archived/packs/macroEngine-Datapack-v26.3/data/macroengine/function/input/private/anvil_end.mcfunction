# macroengine:input/private/anvil_end  [INTERNAL]
# @s = player. Closes the anvil session.
tag @s remove macroengine.anvil_session
tag @s remove macroengine.anvil_hidden
scoreboard players reset @s macroengine.anvil_t
