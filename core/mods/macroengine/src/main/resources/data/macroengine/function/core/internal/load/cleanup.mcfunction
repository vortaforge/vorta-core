# macroengine:core/internal/load/cleanup
# Full reverse of loader/scoreboards + loader/storages + the third (other.mcfunction)
# load-time file. Undoes every init action from those three, in reverse order
# (last-loaded first, so nothing here depends on something already torn down).
#
# Caveats for the best-guess vanilla equivalents used below:
#   - "schedule clear <fn>" cancels the sync_tick schedule set via
#     core/lib/schedule — correct IF that lib wraps vanilla `schedule function`.
#     If it uses its own queue/storage instead, this line does nothing and the
#     entry must be cleared from wherever core/lib/schedule actually tracks it.
#   - There's no known macroengine:core/internal/systems/uuid/cleanup or
#     macroengine:systems/color/cleanup counterpart to the two `function` calls
#     in storages.mcfunction — left as comments, not invented calls.
#   - $epoch is normally preserved across /reload (per the header comment in
#     storages.mcfunction). Since this is a full teardown, not a reload, it's
#     cleared here too — remove that line if you actually want epoch to survive.

# ── reverse of other.mcfunction ──────────────────────────────────────────
# "Assign pid for any players already online" has no real inverse command —
# it's undone by dropping the storage that held the pids (player_pids /
# _pid_seq), further down where loader/storages is reversed.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
tag @s remove macroengine.admin

# text module: working buffers and lookup tables
function macroengine:core/internal/text/unload

kill @e[type=minecraft:command_block_minecart,tag=macroengine_input]

execute if score #sys_admin macroengine.tick_flags matches 1.. run scoreboard players reset #sys_admin macroengine.tick_flags
execute if score #sys_hud macroengine.tick_flags matches 1.. run scoreboard players reset #sys_hud macroengine.tick_flags
execute if score #sys_queue macroengine.tick_flags matches 1.. run scoreboard players reset #sys_queue macroengine.tick_flags
execute if score #sys_player macroengine.tick_flags matches 1.. run scoreboard players reset #sys_player macroengine.tick_flags
execute if score #sys_time macroengine.tick_flags matches 1.. run scoreboard players reset #sys_time macroengine.tick_flags

scoreboard players reset @a[tag=macroengine.admin] macroengine_action
scoreboard players reset @a[tag=macroengine.admin] macroengine_run

schedule clear macroengine:core/lib/sync_tick

forceload remove 0 0

# ── reverse of loader/storages ───────────────────────────────────────────
# Color API — no known cleanup counterpart to `function macroengine:systems/color/init`
# function macroengine:systems/color/cleanup

data remove storage macroengine:engine modules.cb
data remove storage macroengine:engine _cb_entry
data remove storage macroengine:engine _cb_work
data remove storage macroengine:engine _cb_last
data remove storage macroengine:engine cb_queue

data remove storage macroengine:engine modules.geo
data remove storage macroengine:engine modules.wand
data remove storage macroengine:engine modules.perm
data remove storage macroengine:engine modules.block
data remove storage macroengine:engine modules.container
data remove storage macroengine:engine modules.interaction
data remove storage macroengine:engine modules.hook

data remove storage macroengine:engine multiCommands

data remove storage macroengine:engine wand_cooldowns

data remove storage macroengine:engine batches

data remove storage macroengine:engine region_watches

data remove storage macroengine:engine fibers

data remove storage macroengine:engine hook_binds

data remove storage macroengine:engine wand_binds

data remove storage macroengine:engine once_per_player

# UUID module — no known cleanup counterpart to `function macroengine:core/internal/systems/uuid/init`
# function macroengine:core/internal/systems/uuid/cleanup

data remove storage macroengine:engine _pid_seq
data remove storage macroengine:engine player_pids

data remove storage macroengine:engine interaction_binds

data remove storage macroengine:engine trigger_binds

data remove storage macroengine:engine perm_trigger_names
data remove storage macroengine:engine perm_triggers

data remove storage macroengine:engine permissions

data remove storage macroengine:engine states
data remove storage macroengine:engine flags

data remove storage macroengine:engine throttle

scoreboard players reset $pb_four macroengine.tmp
scoreboard players reset $pq_depth macroengine.tmp
scoreboard players reset $tick macroengine.tmp
scoreboard players reset $epoch macroengine.time

# ── reverse of loader/scoreboards ────────────────────────────────────────
scoreboard objectives remove macroengine.state
scoreboard objectives remove macroengine.gamerule
scoreboard objectives remove macroengine.log_level
scoreboard objectives remove macroengine.hook_fish
scoreboard objectives remove macroengine.hook_eat
scoreboard objectives remove macroengine.hook_target_hit
scoreboard objectives remove macroengine.hook_drop
scoreboard objectives remove macroengine.hook_open_chest
scoreboard objectives remove macroengine.hook_jump
scoreboard objectives remove macroengine.Flags
scoreboard objectives remove macroengine.tick_flags
scoreboard objectives remove macroengine.tick
scoreboard objectives remove macroengine.hook_traded
scoreboard objectives remove macroengine.hook_dim_changed
scoreboard objectives remove macroengine.hook_hero_of_the_village
scoreboard objectives remove macroengine.hook_killed_by_arrow
scoreboard objectives remove macroengine.hook_using_item
scoreboard objectives remove macroengine.hook_entity_killed
scoreboard objectives remove macroengine.hook_item_used
scoreboard objectives remove macroengine.hook_tool_used
scoreboard objectives remove macroengine.hook_elytra
scoreboard objectives remove macroengine.hook_sprint
scoreboard objectives remove macroengine.hook_sneak
scoreboard objectives remove macroengine.hook_lvl_new
scoreboard objectives remove macroengine.hook_lvl
scoreboard objectives remove macroengine.hook_placed
scoreboard objectives remove macroengine.hook_deaths
scoreboard objectives remove macroengine.hook_online
scoreboard objectives remove macroengine.rightClick
scoreboard objectives remove macroengine.freeze_id
scoreboard objectives remove macroengine.pid
scoreboard objectives remove macroengine.pre_version
scoreboard objectives remove macroengine_action
scoreboard objectives remove macroengine_run
scoreboard objectives remove macroengine.time
scoreboard objectives remove macroengine.meta
scoreboard objectives remove macroengine.tmp
