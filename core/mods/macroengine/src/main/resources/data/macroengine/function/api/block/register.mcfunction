# macroengine:api/block/register
# Registers a custom block (a block entity backed by a container, or any block you handle yourself).
#
# INPUT  macroengine:input id (name: letters, digits, _ . -), and optional handler function ids:
#        validate, insert, take, hopper_in, hopper_out  ("namespace:path", checked before they are stored)
# Handlers run AT the block (execute positioned x y z) and read macroengine:block ctx
# {op, x, y, z, slot?, item?}. A handler returns 1 for success/allow and 0 for failure/deny.
# A handler may write macroengine:output block.item (take / hopper_out).
# End every handler with an explicit `return 1` (allow) or `return 0` (deny).
# A missing handler falls back to the container defaults (insert/hopper_in: first free slot,
# take/hopper_out: first occupied slot, validate: the block must be a container).
# RETURN 1 registered, 0 refused (bad id, bad function id).
# Players need the macroengine.admin tag; console, load and command-block callers are trusted.

# USAGE
#   data modify storage macroengine:input id set value "my_crate"
#   data modify storage macroengine:input insert set value "mypack:crate/insert"
#   function macroengine:api/block/register
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{block:0b} run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.admin] run return 0
data remove storage macroengine:validate in
data modify storage macroengine:validate in.value set from storage macroengine:input id
execute unless function macroengine:systems/validate/safe_name run return 0
data modify storage macroengine:block tmp set value {reg:{},m:{}}
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_reg_fn {k:"validate"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_reg_fn {k:"insert"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_reg_fn {k:"take"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_reg_fn {k:"hopper_in"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
scoreboard players set #macroengine.chk macroengine.tmp 0
execute store result score #macroengine.chk macroengine.tmp run function macroengine:core/internal/api/block/_reg_fn {k:"hopper_out"}
execute unless score #macroengine.chk macroengine.tmp matches 1.. run return 0
data modify storage macroengine:block tmp.m.id set from storage macroengine:input id
return run function macroengine:core/internal/api/block/_reg_store with storage macroengine:block tmp.m
