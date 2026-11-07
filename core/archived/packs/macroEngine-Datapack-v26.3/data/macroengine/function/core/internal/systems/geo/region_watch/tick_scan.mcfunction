# macroengine:systems/geo/region_watch/internal/tick_scan
# Called directly from core/tick/queue_systems.mcfunction.
# If region_watches is non-empty, checks all regions for each player.

# Module toggle guard — skips this module when disabled via macroengine:api/toggle/geo/false
execute unless data storage macroengine:engine {modules:{geo:1b}} run return 0
scoreboard players operation #scan_mod macroengine.tick = #tick_ctr macroengine.tick
scoreboard players operation #scan_mod macroengine.tick %= #geo_interval macroengine.tick
execute unless score #scan_mod macroengine.tick matches 0 run return 0

execute unless data storage macroengine:engine region_watches run return 0

execute as @a run function macroengine:core/internal/systems/geo/region_watch/player_scan
