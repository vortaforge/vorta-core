# Unregister a trigger. Removes the registry entry only - the scoreboard objective itself
# is left in place (vanilla has no clean way to remove an objective's data mid-session
# without affecting player scores unexpectedly; operators can `/scoreboard objectives
# remove <obj>` manually if desired).
# Required storage keys: trigger.objective (string).
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage rtwrapper:api trigger.objective run return fail
function rtwrapper:core/trigger/unregister_apply with storage rtwrapper:api trigger
data remove storage rtwrapper:api trigger
