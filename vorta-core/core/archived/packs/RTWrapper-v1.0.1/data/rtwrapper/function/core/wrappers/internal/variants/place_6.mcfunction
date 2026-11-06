# RTWrapper generated 6-parameter macro variant for /place.
# Parameters: type, id, pos, rotation, mirror, integrity
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$place $(type) $(id) $(pos) $(rotation) $(mirror) $(integrity)
