# guikit :: core/tick

execute as @a[scores={guikit.timer=1..}] run scoreboard players remove @s guikit.timer 1
execute as @a[scores={guikit.timer=0}] at @s run function guikit:api/close

execute as @a[scores={guikit.cd=1..}] run scoreboard players remove @s guikit.cd 1

scoreboard players enable @a guikit.last
scoreboard players enable @a guikit.close
execute as @a[scores={guikit.last=1..}] at @s run function guikit:runtime/last_trigger
execute as @a[scores={guikit.close=1..}] run function guikit:api/close_self

execute as @a[scores={guikit.timer=1..}] at @s run function guikit:core/player_tick

# tick_while_on extension point (guigen toggle.tick_while_on)
execute as @a[scores={guikit.timer=1..}] at @s run function #guikit:while_on

# Cursor vacuum (all players)
execute as @a at @s if items entity @s player.cursor *[minecraft:custom_data~{guikit:{}}] run item replace entity @s player.cursor with minecraft:air

# Drop path
execute as @e[type=minecraft:item,nbt={Item:{components:{"minecraft:custom_data":{guikit:{widget:1}}}}}] at @s run function guikit:internal/click/drop
kill @e[type=minecraft:item,nbt={Item:{components:{"minecraft:custom_data":{guikit:{widget:1}}}}}]
