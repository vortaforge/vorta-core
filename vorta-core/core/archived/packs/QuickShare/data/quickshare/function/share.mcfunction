# /function quickshare:share
# Drops a copy of the item in the executing player's main hand at their feet
# (the original stays in hand), with a per-player 5s (100 tick) cooldown
# tracked on qs_cooldown. Uses a summoned item entity as a scratch entity
# to clone the item's NBT via /data (see drop_mainhand_copy).
#
# Order matters: both guards below read the cooldown as it was when this
# function started, so the drop and the cooldown reset must not be chained on
# the value written by the reset itself. An empty hand does not start a cooldown.
execute if score @s qs_cooldown matches 1.. run tellraw @s {"text":"[QuickShare] Cooldown active.","color":"red"}
execute unless score @s qs_cooldown matches 1.. if data entity @s SelectedItem at @s run function quickshare:drop_mainhand_copy
execute unless score @s qs_cooldown matches 1.. if data entity @s SelectedItem run scoreboard players set @s qs_cooldown 100
