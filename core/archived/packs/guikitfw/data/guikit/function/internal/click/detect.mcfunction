# click score: 0 idle, 1 detected (handler runs), 2 handled
# NOTE: nothing in this pack calls this function. core/player_tick_entity and
# core/player_tick_block run internal/click/shift and then internal/click/maybe_left,
# which runs the left-click scan only when storage guikit:cfg click_detection contains
# "left" (default ["shift"]). Drops are handled in core/tick and ignore that key.
# This function runs shift and then left unconditionally; do not rely on it for cfg.

execute if score @s guikit.click matches 1.. run return 0
function guikit:internal/click/shift
execute if score @s guikit.click matches 1.. run return 0
function guikit:internal/click/left
