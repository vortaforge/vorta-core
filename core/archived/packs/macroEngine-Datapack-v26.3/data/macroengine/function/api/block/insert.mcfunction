# macroengine:api/block/insert
# Puts an item into a registered custom block.
#
# INPUT  macroengine:input id (registered block), x, y, z (ints), slot (optional), item {id, count, components}
# OUTPUT macroengine:output block {ok, denied}
# RETURN 1 success, 0 refused / denied / failed. Order: validate handler, then the insert handler.
# Handlers run AT the block (execute positioned x y z) and read macroengine:block ctx
# {op, x, y, z, slot?, item?}. A handler returns 1 for success/allow and 0 for failure/deny.
# A handler may write macroengine:output block.item (take / hopper_out).
# End every handler with an explicit `return 1` (allow) or `return 0` (deny).
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{block:0b} run return 0
data modify storage macroengine:output block set value {ok:0b,denied:0b}
data modify storage macroengine:block tmp set value {m:{op:"insert"}}
execute unless function macroengine:core/internal/api/block/_prepare run return 0
return run function macroengine:core/internal/api/block/_run
