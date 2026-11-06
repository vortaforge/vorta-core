# Enable a registered RTWrapper trigger (it will fire again when set). No-op if unregistered
# or already enabled.
# Required storage keys: trigger.objective (string).
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage rtwrapper:api trigger.objective run return fail
function rtwrapper:core/trigger/set_enabled with storage rtwrapper:api trigger
data remove storage rtwrapper:api trigger
