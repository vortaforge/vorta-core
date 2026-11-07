# macroengine:input/private/anvil_tick  [INTERNAL]
# @s = player with an open anvil session, at @s. Called every tick by input/anvil.

# Session timeout: 1200 ticks = 60 seconds after the anvil was opened.
scoreboard players add @s macroengine.anvil_t 1
execute if score @s macroengine.anvil_t matches 1200.. run return run function macroengine:input/private/anvil_end

# Is the carrier visible in the inventory? (hotbar, main inventory, offhand)
scoreboard players set #macroengine.AnvilVis macroengine.tmp 0
execute if items entity @s hotbar.* *[minecraft:custom_data~{macroengine:{input:1b,inputItem:"anvil"}}] run scoreboard players set #macroengine.AnvilVis macroengine.tmp 1
execute if score #macroengine.AnvilVis macroengine.tmp matches 0 if items entity @s inventory.* *[minecraft:custom_data~{macroengine:{input:1b,inputItem:"anvil"}}] run scoreboard players set #macroengine.AnvilVis macroengine.tmp 1
execute if score #macroengine.AnvilVis macroengine.tmp matches 0 if items entity @s weapon.offhand *[minecraft:custom_data~{macroengine:{input:1b,inputItem:"anvil"}}] run scoreboard players set #macroengine.AnvilVis macroengine.tmp 1

# Back in the inventory: it was never in, or has left, the anvil slot. Whatever
# was proven before no longer holds.
execute if score #macroengine.AnvilVis macroengine.tmp matches 1 run tag @s remove macroengine.anvil_hidden
execute if score #macroengine.AnvilVis macroengine.tmp matches 1 run return 0

# Not in the inventory, on the cursor, renamed, and previously hidden in the
# anvil slot: this is the rename result being taken out. Capture and finish.
execute if entity @s[tag=macroengine.anvil_hidden] if items entity @s player.cursor *[minecraft:custom_data~{macroengine:{input:1b,inputItem:"anvil"}},minecraft:custom_name] run return run function macroengine:input/private/anvil_done

# Not in the inventory and not on the cursor: it can only be in the anvil input slot.
execute unless items entity @s player.cursor *[minecraft:custom_data~{macroengine:{input:1b,inputItem:"anvil"}}] run tag @s add macroengine.anvil_hidden
