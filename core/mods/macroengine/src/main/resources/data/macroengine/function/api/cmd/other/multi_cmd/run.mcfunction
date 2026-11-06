# ─────────────────────────────────────────────────────────────────
# macroengine:api/cmd/other/multi_cmd/run
# Execute queued commands
# ─────────────────────────────────────────────────────────────────

# Reset statistics
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cmd:0b} run return 0
execute if score #perm_cmd macroengine.tick_flags matches 1 run data modify storage macroengine:perm_require in set value {perm:"cmd.other.multi_cmd.run"}
execute if score #perm_cmd macroengine.tick_flags matches 1 unless function macroengine:api/perm/require run return 0
execute if data storage macroengine:engine _mcmd_options{profile:1b} run data modify storage macroengine:engine _mcmd_stats set value {total:0,success:0,skipped:0,start_time:0,duration:0,exec_time:0}
execute if data storage macroengine:engine _mcmd_options{profile:1b} run scoreboard players set $mcmd_total macroengine.tmp 0
execute if data storage macroengine:engine _mcmd_options{profile:1b} run scoreboard players set $mcmd_success macroengine.tmp 0
execute if data storage macroengine:engine _mcmd_options{profile:1b} run scoreboard players set $mcmd_skipped macroengine.tmp 0
execute if data storage macroengine:engine _mcmd_options{profile:1b} run scoreboard players set $mcmd_exec_total macroengine.tmp 0
execute if data storage macroengine:engine _mcmd_options{profile:1b} run execute store result storage macroengine:engine _mcmd_stats.start_time int 1 run time query gametime

# Start recursive stepping
function macroengine:core/internal/api/cmd/other/multi_cmd/step

# Cleanup
function macroengine:core/internal/api/cmd/other/multi_cmd/cleanup

# Show statistics
execute if data storage macroengine:engine _mcmd_options{profile:1b} run function macroengine:core/internal/api/cmd/other/multi_cmd/show_stats
