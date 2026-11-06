# macroengine:systems/geo/region_watch/internal/player_scan
# @s = the player to check
# Reads coordinates to storage, then iterates all regions.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _rw_iter set from storage macroengine:engine region_watches

# Write player coordinates to _rw_player (int truncation, consistent with geo module)
execute store result storage macroengine:engine _rw_player.x int 1 run data get entity @s Pos[0]
execute store result storage macroengine:engine _rw_player.y int 1 run data get entity @s Pos[1]
execute store result storage macroengine:engine _rw_player.z int 1 run data get entity @s Pos[2]

function macroengine:core/internal/systems/geo/region_watch/region_loop

data remove storage macroengine:engine _rw_iter
data remove storage macroengine:engine _rw_player
