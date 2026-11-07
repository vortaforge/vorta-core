# The work queue (and its drain loop) is the lib module. Reached through the
# queue_process slot, so an install without lib simply has nothing to drain.
function #macroengine:hook/queue_process

# CB fire cooldown (see core/internal/systems/cb/process_step)
execute if score #cb_cd macroengine.tmp matches 1.. run scoreboard players remove #cb_cd macroengine.tmp 1

# CB delay queue — process pending command block executions
execute if data storage macroengine:engine modules{cb:1b} run execute if data storage macroengine:engine cb_queue[0] run function macroengine:core/internal/systems/cb/tick
