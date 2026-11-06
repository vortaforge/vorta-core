# Direct named-parameter API for /spreadplayers.
# Parameter order: center, spread_distance, max_range, height_mode, respect_teams, targets
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
data modify storage rtwrapper:runtime current.params set from storage rtwrapper:api params
function rtwrapper:core/wrappers/internal/spreadplayers
data remove storage rtwrapper:runtime current.params
