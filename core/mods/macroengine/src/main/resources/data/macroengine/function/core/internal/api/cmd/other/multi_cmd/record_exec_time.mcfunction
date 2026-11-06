# ─────────────────────────────────────────────────────────────────
# macroengine:core/internal/api/cmd/other/multi_cmd/record_exec_time
# Accumulates the elapsed gametime of the entry just executed.
#
# The previous version computed the duration and then immediately reset
# the score holding it, so the value never reached _mcmd_stats and the
# reported duration was always 0. The duration is now added into a
# running total that show_stats reads.
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute store result score $mcmd_exec_end macroengine.tmp run time query gametime

scoreboard players operation $mcmd_exec_dur macroengine.tmp = $mcmd_exec_end macroengine.tmp
scoreboard players operation $mcmd_exec_dur macroengine.tmp -= $mcmd_exec_start macroengine.tmp

# Accumulate. A negative delta means gametime wrapped or was set
# backwards; count it as zero rather than corrupting the total.
execute if score $mcmd_exec_dur macroengine.tmp matches ..-1 run scoreboard players set $mcmd_exec_dur macroengine.tmp 0
scoreboard players operation $mcmd_exec_total macroengine.tmp += $mcmd_exec_dur macroengine.tmp

scoreboard players reset $mcmd_exec_start macroengine.tmp
scoreboard players reset $mcmd_exec_end macroengine.tmp
scoreboard players reset $mcmd_exec_dur macroengine.tmp
