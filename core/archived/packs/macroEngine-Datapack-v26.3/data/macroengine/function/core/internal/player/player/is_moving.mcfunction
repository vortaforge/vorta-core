# macroEngine player module — movement detection.
# Compares the current position with the cached one (scaled by 70 to keep
# sub-block motion visible after the int cast); any axis change marks the
# player as moving, then the cache is refreshed.

data modify storage macroengine:core/internal/player/temp list set from entity @s Pos

# X axis
execute store result score #x player_action.data run data get storage macroengine:core/internal/player/temp list[0] 70
scoreboard players operation #temp player_action.data = #x player_action.data
scoreboard players operation #temp player_action.data -= @s player_action.x
execute unless score #temp player_action.data matches 0 run tag @s add player_action.moving

# Y axis
execute store result score #y player_action.data run data get storage macroengine:core/internal/player/temp list[1] 70
scoreboard players operation #temp player_action.data = #y player_action.data
scoreboard players operation #temp player_action.data -= @s player_action.y
execute unless score #temp player_action.data matches 0 run tag @s add player_action.moving

# Z axis
execute store result score #z player_action.data run data get storage macroengine:core/internal/player/temp list[2] 70
scoreboard players operation #temp player_action.data = #z player_action.data
scoreboard players operation #temp player_action.data -= @s player_action.z
execute unless score #temp player_action.data matches 0 run tag @s add player_action.moving

# Refresh the cache for the next tick
scoreboard players operation @s player_action.x = #x player_action.data
scoreboard players operation @s player_action.y = #y player_action.data
scoreboard players operation @s player_action.z = #z player_action.data
