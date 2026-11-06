# Disable a registered RTWrapper trigger (score changes are ignored by poll until
# re-enabled). No-op if unregistered.
# Required storage keys: trigger.objective (string).
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage rtwrapper:api trigger.objective run return fail
data modify storage rtwrapper:api trigger.enabled set value 0b
function rtwrapper:core/trigger/set_enabled with storage rtwrapper:api trigger
data remove storage rtwrapper:api trigger
