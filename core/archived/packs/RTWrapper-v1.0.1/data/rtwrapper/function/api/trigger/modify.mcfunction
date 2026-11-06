# Modify an existing trigger's action and/or reset_mode. No-op if unregistered.
# Required storage keys: trigger.objective (string).
# Optional: trigger.action (compound), trigger.reset_mode ("value"|"keep").
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage rtwrapper:api trigger.objective run return fail
function rtwrapper:core/trigger/modify_check with storage rtwrapper:api trigger
data remove storage rtwrapper:api trigger
