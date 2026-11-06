# macroengine:api/cb/time_left
# ─────────────────────────────────────────────────────────────────
# Reports how long until the NEXT pending entry of one run_delayed /
# run_sequence / run_repeating call fires. Read-only: the queue is not changed.
#
# INPUT  (storage macroengine:input cb):
#   id      (int)  — the cb_id returned by the scheduling call  [REQUIRED, >= 1]
#
# OUTPUT (storage macroengine:output):
#   cb_time_left  (int)  — ticks until the next entry of that id fires, or -1 when none is pending
#   cb_pending    (int)  — how many entries of that id are still queued (0 once everything fired)
#
# RETURN 1 when at least one entry is pending, else 0.
# The id is read as a number and compared on a scoreboard; it is never pasted into a macro.
# Entries pushed back by the fire spacing (see docs/cb.md) report their current counter.
#
# EXAMPLE:
#   data modify storage macroengine:input cb set value {cmd:"say hi",delay:100}
#   function macroengine:api/cb/run_delayed
#   data modify storage macroengine:input cb.id set from storage macroengine:output cb_id
#   function macroengine:api/cb/time_left
# ─────────────────────────────────────────────────────────────────

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute if data storage macroengine:engine modules{cb:0b} run return 0
execute unless data storage macroengine:input cb.id run tellraw @s [{"text":"[MACROENGINE/cb] ","color":"#00AAAA","bold":true},{"text":"cb.id not set","color":"red"}]
execute unless data storage macroengine:input cb.id run return 0
scoreboard players set #cb_cid macroengine.tmp 0
execute store result score #cb_cid macroengine.tmp run data get storage macroengine:input cb.id
data remove storage macroengine:input cb
data modify storage macroengine:output cb_time_left set value -1
data modify storage macroengine:output cb_pending set value 0
execute unless score #cb_cid macroengine.tmp matches 1.. run return 0

scoreboard players set #cb_tcount macroengine.tmp 0
scoreboard players set #cb_tmin macroengine.tmp -1
data modify storage macroengine:engine _cb_twork set from storage macroengine:engine cb_queue
execute if data storage macroengine:engine _cb_twork[0] run function macroengine:core/internal/systems/cb/time_left_step
data remove storage macroengine:engine _cb_twork
data remove storage macroengine:engine _cb_tentry
execute store result storage macroengine:output cb_pending int 1 run scoreboard players get #cb_tcount macroengine.tmp
execute store result storage macroengine:output cb_time_left int 1 run scoreboard players get #cb_tmin macroengine.tmp
execute if score #cb_tcount macroengine.tmp matches 1.. run return 1
return 0
