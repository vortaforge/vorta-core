# Called by quickshare:share with execution at the player (only when the
# player's main hand is not empty).
# Summons a scratch item entity, overwrites its Item with the player's mainhand
# stack via /data (the standard "clone an item stack via NBT" pattern for
# datapacks, since there is no direct "give a copy of this slot" command),
# then lets it exist as a normal dropped item.
#
# The scratch entity must start with a non-empty placeholder stack: an item
# entity summoned with minecraft:air is an empty stack and is not kept, so the
# copy below would have nothing to write into. The placeholder is always
# replaced before the entity is released; if the copy fails, the entity is
# still tagged qs_pending and is killed at the end, so no placeholder is dropped.
summon minecraft:item ~ ~1 ~ {Item:{id:"minecraft:stone",count:1},PickupDelay:10,Tags:["qs_pending"]}
execute as @e[type=minecraft:item,tag=qs_pending,limit=1,sort=nearest] if data entity @p SelectedItem run data modify entity @s Item set from entity @p SelectedItem
execute as @e[type=minecraft:item,tag=qs_pending,limit=1,sort=nearest] if data entity @p SelectedItem run tag @s remove qs_pending
execute as @e[type=minecraft:item,tag=qs_pending] run kill @s
