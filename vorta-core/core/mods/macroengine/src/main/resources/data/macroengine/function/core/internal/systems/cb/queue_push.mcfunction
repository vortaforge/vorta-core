# macroengine:systems/cb/internal/queue_push
# Reads macroengine:input cb {cmd, delay, x, y, z}; no macro, so nothing from the
# caller is pasted into SNBT (a cmd containing a quote can no longer break out of
# the entry or inject keys).
# Appends {cmd, x, y, z, ticks_left, id} to macroengine:engine cb_queue and writes
# the entry id to macroengine:output cb_id (use it with api/cb/cancel_id).

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_new set from storage macroengine:input cb
execute store result storage macroengine:engine _cb_new.ticks_left int 1 run data get storage macroengine:input cb.delay
data remove storage macroengine:engine _cb_new.delay
scoreboard players add #cb_next_id macroengine.tmp 1
execute store result storage macroengine:engine _cb_new.id int 1 run scoreboard players get #cb_next_id macroengine.tmp
execute store result storage macroengine:output cb_id int 1 run scoreboard players get #cb_next_id macroengine.tmp
data modify storage macroengine:engine cb_queue append from storage macroengine:engine _cb_new
data remove storage macroengine:engine _cb_new
