# macroEngine player module — per-player tick pipeline (@s = one player).
# Order matters: clear last tick's state, refresh identity, detect movement,
# dispatch accumulated events, let click detection run, zero the counters,
# then hand over to user hooks.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
function macroengine:core/internal/player/player/remove_tags

# First sight of this player: cache the UUID
execute unless score @s player_action.uuid.0 matches -2147483648.. run function macroengine:core/internal/player/player/set_uuid

function macroengine:core/internal/player/player/is_moving
function macroengine:core/internal/player/player/process_data
function macroengine:core/internal/player/click_detection/tick

function macroengine:core/internal/player/player/reset_scores

# User-facing per-player hook
function #macroengine:core/internal/player/tick
