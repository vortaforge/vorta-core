# macroengine:api/cb/run_delayed
# ─────────────────────────────────────────────────────────────────
# Schedules a command string to execute via command block after a delay.
#
# INPUT  (storage macroengine:input cb):
#   cmd     (string)  — the command to run    [REQUIRED]
#   delay   (int)     — delay in ticks        [REQUIRED, min 1]
#   x       (int)     — CB block X            [default: 0]
#   y       (int)     — CB block Y            [default: -64]
#   z       (int)     — CB block Z            [default: 0]
#
# OUTPUT (storage macroengine:output):
#   cb_id   (int)  — id of the queued entry, usable with api/cb/cancel_id
#
# No permission gate — caller is trusted as-is.
#
# EXAMPLE:
#   data modify storage macroengine:input cb set value {cmd:"say delayed!",delay:40}
#   function macroengine:api/cb/run_delayed
# ─────────────────────────────────────────────────────────────────

# Verify required inputs
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute unless data storage macroengine:input cb.cmd run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.cmd not set","color":"red"}]
execute unless data storage macroengine:input cb.cmd run return 0
execute unless data storage macroengine:input cb.delay run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.delay not set","color":"red"}]
execute unless data storage macroengine:input cb.delay run return 0

# Fill coordinate defaults
function macroengine:core/internal/api/cb/apply_defaults

# Push to delay queue and schedule flush
function macroengine:core/internal/systems/cb/queue_push
data remove storage macroengine:input cb
