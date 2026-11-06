# macroengine:systems/cmd_gate/_block_loop [INTERNAL]
# Walks macroengine:cmd_gate tmp.pending once, comparing each entry with
# tmp.root. String equality is the data-modify trick used by
# core/internal/text/find_loop: copying an equal value changes nothing, so
# store success is 0 exactly when the two strings match. No macro line ever
# touches the command text.

execute unless score #macroengine.open vortaforge.gate matches 1 run return 0
execute if entity @s[type=minecraft:player] unless entity @s[tag=macroengine.consented] unless score #macroengine.gate.3 vortaforge.gate matches 0 run return 0
execute unless data storage macroengine:cmd_gate tmp.pending[0] run return 0
data modify storage macroengine:cmd_gate tmp.cmp set from storage macroengine:cmd_gate tmp.root
execute store success score #macroengine.cg_diff macroengine.tmp run data modify storage macroengine:cmd_gate tmp.cmp set from storage macroengine:cmd_gate tmp.pending[0]
execute if score #macroengine.cg_diff macroengine.tmp matches 0 run data modify storage macroengine:cmd_gate tmp.blocked set value 1b
data remove storage macroengine:cmd_gate tmp.pending[0]
execute unless data storage macroengine:cmd_gate tmp{blocked:1b} run function macroengine:systems/cmd_gate/_block_loop
