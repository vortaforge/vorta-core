# RTWrapper generated 6-parameter macro variant for /item.
# Parameters: action, target_kind, target, slot, modifier, source_kind
execute unless score #rtwrapper.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=rtwrapper.consented] unless score #rtwrapper.gate.3 vortaforge.gate matches 0 run return 0
$item $(action) $(target_kind) $(target) $(slot) $(modifier) $(source_kind)
