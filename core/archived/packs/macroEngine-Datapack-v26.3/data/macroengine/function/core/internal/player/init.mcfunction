# macroEngine player module — init (load step 3 of 3).
# Starts the two loops and registers every scoreboard the module reads from.
# Objective names are the module's stable interface (hooks and other systems
# read player_action.*), so they are intentionally kept.

# Loops: per-player tick (1t) and entity click-detection maintenance (100t)
schedule function macroengine:core/internal/player/tick 5t
schedule function macroengine:core/internal/player/click_detection/tick_entities 100t

# Scratch storage used by the per-player pipeline
data merge storage macroengine:core/internal/player/temp {list:[], obj:{}, var:""}

# Generic scratch + identity
scoreboard objectives add player_action.data dummy
scoreboard objectives add player_action.uuid.0 dummy
scoreboard objectives add player_action.uuid.1 dummy
scoreboard objectives add player_action.uuid.2 dummy
scoreboard objectives add player_action.uuid.3 dummy

# Cached position (movement detection)
scoreboard objectives add player_action.x dummy
scoreboard objectives add player_action.y dummy
scoreboard objectives add player_action.z dummy

# Movement statistics (per-tick deltas feed the movement tags)
scoreboard objectives add player_action.aviate minecraft.custom:minecraft.aviate_one_cm
scoreboard objectives add player_action.climb minecraft.custom:minecraft.climb_one_cm
scoreboard objectives add player_action.fall minecraft.custom:minecraft.fall_one_cm
scoreboard objectives add player_action.fly minecraft.custom:minecraft.fly_one_cm
scoreboard objectives add player_action.walk minecraft.custom:minecraft.walk_one_cm
scoreboard objectives add player_action.jump minecraft.custom:minecraft.jump

# Event counters (dispatched once per tick, then reset)
scoreboard objectives add player_action.death minecraft.custom:minecraft.deaths
scoreboard objectives add player_action.join minecraft.custom:minecraft.leave_game
scoreboard objectives add player_action.enchant minecraft.custom:minecraft.enchant_item
scoreboard objectives add player_action.use_coas minecraft.used:minecraft.carrot_on_a_stick
scoreboard objectives add player_action.use_wfoas minecraft.used:minecraft.warped_fungus_on_a_stick
