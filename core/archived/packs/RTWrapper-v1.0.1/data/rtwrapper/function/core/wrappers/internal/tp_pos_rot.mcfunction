# Convenience macro wrapper for: /tp <target> <x> <y> <z> <rotation>
# Required storage keys: target, x, y, z, rotation.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$tp $(target) $(x) $(y) $(z) $(rotation)
