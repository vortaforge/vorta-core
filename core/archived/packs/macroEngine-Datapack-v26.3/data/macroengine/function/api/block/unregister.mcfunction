# macroengine:api/block/unregister
# Removes a registered custom block.
# INPUT  macroengine:input id   RETURN 1 done, 0 refused. Same caller rule as register.
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{block:0b} run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.admin] run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input id
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:block tmp set value {m:{}}
data modify storage macroengine:block tmp.m.id set from storage macroengine:input id
return run function macroengine:core/internal/api/block/_unreg with storage macroengine:block tmp.m
