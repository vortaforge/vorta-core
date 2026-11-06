# RTWrapper generated 5-parameter macro variant for /data.
# Parameters: action, target_kind, target, path, operation
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$data $(action) $(target_kind) $(target) $(path) $(operation)
