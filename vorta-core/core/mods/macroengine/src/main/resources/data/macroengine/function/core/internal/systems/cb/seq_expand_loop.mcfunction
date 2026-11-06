# macroengine:systems/cb/internal/seq_expand_loop
# Pops first cmd from _cb_seq.cmds, computes its delay, pushes to queue.

# Increment step counter and compute cumulative delay
execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
scoreboard players add #cb_seq_step macroengine.tmp 1
execute store result score #cb_delay macroengine.tmp run scoreboard players get #cb_seq_step macroengine.tmp
scoreboard players operation #cb_delay macroengine.tmp *= #cb_seq_idx macroengine.tmp

# Pop cmd from list into scratch
data modify storage macroengine:engine _cb_seq_cmd set from storage macroengine:engine _cb_seq.cmds[0]
data remove storage macroengine:engine _cb_seq.cmds[0]

# Write queue entry
function macroengine:core/internal/systems/cb/seq_push_entry

# Continue if more cmds remain
execute if data storage macroengine:engine _cb_seq.cmds[0] run function macroengine:core/internal/systems/cb/seq_expand_loop
