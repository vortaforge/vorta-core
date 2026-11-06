# Direct named-parameter API for /data.
# Parameter order: action, target_kind, target, path, operation, source_kind, source, source_path, value
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
data modify storage rtwrapper:runtime current.params set from storage rtwrapper:api params
function rtwrapper:core/wrappers/internal/data
data remove storage rtwrapper:runtime current.params
