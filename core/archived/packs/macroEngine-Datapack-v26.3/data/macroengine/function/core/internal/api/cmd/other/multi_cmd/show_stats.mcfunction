# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/show_stats
# Writes the run's statistics to _mcmd_stats and reports them.
#
# The previous version computed
#     $mcmd_duration = $mcmd_end_time
#     $mcmd_duration -= $mcmd_duration
# which is unconditionally 0 — the start_time it had just read was
# discarded on the next line. Wall-clock duration and per-entry
# execution time are both real numbers now.
# ─────────────────────────────────────────────────────────────────

execute store result score $mcmd_end_time macroengine.tmp run time query gametime
execute store result score $mcmd_start_time macroengine.tmp run data get storage macroengine:engine _mcmd_stats.start_time

scoreboard players operation $mcmd_duration macroengine.tmp = $mcmd_end_time macroengine.tmp
scoreboard players operation $mcmd_duration macroengine.tmp -= $mcmd_start_time macroengine.tmp
execute if score $mcmd_duration macroengine.tmp matches ..-1 run scoreboard players set $mcmd_duration macroengine.tmp 0

execute store result storage macroengine:engine _mcmd_stats.total int 1 run scoreboard players get $mcmd_total macroengine.tmp
execute store result storage macroengine:engine _mcmd_stats.success int 1 run scoreboard players get $mcmd_success macroengine.tmp
execute store result storage macroengine:engine _mcmd_stats.skipped int 1 run scoreboard players get $mcmd_skipped macroengine.tmp
execute store result storage macroengine:engine _mcmd_stats.duration int 1 run scoreboard players get $mcmd_duration macroengine.tmp
execute store result storage macroengine:engine _mcmd_stats.exec_time int 1 run scoreboard players get $mcmd_exec_total macroengine.tmp

data modify storage macroengine:output stats set from storage macroengine:engine _mcmd_stats

tellraw @a[tag=macroengine.admin] ["",{"text":"[MACROENGINE] ","color":"#00AAAA","bold":true},{"text":"multi_cmd profile ","color":"gray"},{"text":"→ ","color":"#555555"},{"plain":true,"interpret":false,"storage":"macroengine:engine","nbt":"_mcmd_stats","color":"white"}]

scoreboard players reset $mcmd_total macroengine.tmp
scoreboard players reset $mcmd_success macroengine.tmp
scoreboard players reset $mcmd_skipped macroengine.tmp
scoreboard players reset $mcmd_exec_total macroengine.tmp
scoreboard players reset $mcmd_duration macroengine.tmp
scoreboard players reset $mcmd_start_time macroengine.tmp
scoreboard players reset $mcmd_end_time macroengine.tmp
data remove storage macroengine:engine _mcmd_stats
