# Convenience macro wrapper for: /give <target> <item>[components] <count>
# Required storage keys: target, item, components, count. Use components:"" when omitted.
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$give $(target) $(item)$(components) $(count)
