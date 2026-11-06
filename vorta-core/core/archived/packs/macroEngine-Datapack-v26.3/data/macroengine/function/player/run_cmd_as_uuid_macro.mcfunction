execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
# Dynamic commands are off by default (config dynamic_cmd). See docs/cmd_gate.md.
execute unless data storage macroengine:engine config{dynamic_cmd:1b} run return 0
$execute as @a[nbt={UUID:$(uuid)}] run $(cmd)
