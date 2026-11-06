# macroengine:systems/cb/internal/seq_push_entry
# Pushes current sequence step as a cb_queue entry.
# Reads: _cb_seq_cmd (string), _cb_delay (score), _cb_seq.{x,y,z}

# Build entry storage
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
data modify storage macroengine:engine _cb_seq_entry set from storage macroengine:engine _cb_seq
data remove storage macroengine:engine _cb_seq_entry.cmds
data remove storage macroengine:engine _cb_seq_entry.interval
data modify storage macroengine:engine _cb_seq_entry.cmd set from storage macroengine:engine _cb_seq_cmd
execute store result storage macroengine:engine _cb_seq_entry.ticks_left int 1 run scoreboard players get #cb_delay macroengine.tmp

execute store result storage macroengine:engine _cb_seq_entry.id int 1 run scoreboard players get #cb_next_id macroengine.tmp
data modify storage macroengine:engine cb_queue append from storage macroengine:engine _cb_seq_entry
data remove storage macroengine:engine _cb_seq_entry
data remove storage macroengine:engine _cb_seq_cmd
