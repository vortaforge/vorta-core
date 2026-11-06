# macroengine:systems/validate/_fid_loop [INTERNAL]
# Checks every entry of macroengine:validate fid.segs with safe_name (an empty entry fails).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:validate fid.segs[0] run return 1
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:validate fid.segs[0]
execute unless function macroengine:systems/validate/safe_name run return 0
data remove storage macroengine:validate fid.segs[0]
return run function macroengine:systems/validate/_fid_loop
