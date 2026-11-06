# Macro: called with storage rtwrapper:runtime trigger_poll (field: index, an int, already
# incremented by poll_step). Recurses into poll_step if registry[index] exists.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$execute if data storage rtwrapper:triggers registry[$(index)] run function rtwrapper:core/trigger/poll_step with storage rtwrapper:runtime trigger_poll
