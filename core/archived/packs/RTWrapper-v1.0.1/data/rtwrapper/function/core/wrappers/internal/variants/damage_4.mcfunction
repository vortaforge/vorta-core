# RTWrapper generated 4-parameter macro variant for /damage.
# Parameters: target, amount, damage_type, location_or_by
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$damage $(target) $(amount) $(damage_type) $(location_or_by)
